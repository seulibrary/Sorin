import { saveAs } from "file-saver"
import { uuidv4 } from "../utils"
import { openModal } from "./modal"
import Constants from "../constants"

export const uploadFile = (channel, type, collection_id, resource_id, file) => {
    return dispatch => {
        dispatch(startUploadFile())

        let reader = new FileReader()

        reader.addEventListener(
            "load",
            () => {
                let payload = {
                    collection_id: parseInt(collection_id),
                    resource_id: parseInt(resource_id),
                    type: type,
                    binary: reader.result.split(",", 2)[1],
                    filename: file.name
                }

                channel.push("upload_file", payload).receive("ok", payload => {}).receive("error", resp => {
                    dispatch(
                        openModal({
                            id: uuidv4,
                            type: "alert",
                            panel: "collection",
                            text: "Error: The file was not uploaded.",
                            message: resp.msg
                        })
                    )

                    dispatch(fileStatusReset())
                })
            },
            false
        )

        reader.readAsDataURL(file)
    }
}

export const startUploadFile = () => {
    return dispatch => {
        dispatch({
            type: Constants.FILE_START_UPLOAD
        })
    }
}

export const startDeleteFile = (file) => {
    return dispatch => {
        dispatch({
            type: Constants.FILE_START_DELETE,
            payload: file
        })
    }
}

export const fileStatusReset = () => {
    return dispatch => {
        dispatch({
            type: Constants.FILE_RESET_STATUS
        })
    }
}

export const downloadFile = (id, port) => {
    let data = new FormData()
    let filename = ""

    data.append("user", window.userToken)

    fetch("/" + port + "/api/file/" + id, {
        method: "POST",
        headers: {
            "x-csrf-token": window.csrfToken
        },
        body: data
    }).then(processStatus)
        .then(function (resp) {
            filename = resp.headers.get("x-filename")

            return resp.blob()
        }).then(blob => {
            saveAs(blob, filename)
        })
}


export const deleteFile = (channel, file_id, collection_id = null) => {
    return dispatch => {
        channel.push("delete_file", {
            file_id: file_id,
            collection_id: collection_id
        }).receive("ok", payload => {
            dispatch(fileStatusReset())
        })
    }
}

const processStatus = function (response) {
    if (response.status === 200 || response.status === 0) {
        return Promise.resolve(response)
    } else {
        return Promise.reject(new Error("Error loading"))
    }
}
