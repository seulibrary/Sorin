import Constants from "../constants"
import { hostUrl } from "../utils"

export const getCollection = (port, url) => (dispatch) => {

    dispatch({
        type: Constants.GETTING_COLLECTION_BY_URL
    })

    fetch(hostUrl + ":" + port + "/api/collection/" + url, {
        method: "GET",
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