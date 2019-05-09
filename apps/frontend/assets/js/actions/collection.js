import Constants from "../constants"
import { hostUrl } from "../utils"

export const getCollection = (port, url) => (dispatch) => {

    dispatch({
        type: Constants.GETTING_COLLECTION_BY_URL
    })

    const body = {
        url: url
    }

    fetch(hostUrl + ":" + port + "/api/collection", {
        method: "POST",
        headers: {
            "x-csrf-token": window.csrfToken,
            Accept: "application/json",
            "Content-Type": "application/json"
        },
        body: JSON.stringify(body)
    }).then(parseJson)
        .then((json) => {
            dispatch({
                type: Constants.GET_COLLECTION_BY_URL,
                payload: json
            })
        })
}

const parseJson = (resp) => {
    return resp.json()
}