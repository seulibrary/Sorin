import Constants from "../constants"
import { apiUrl } from "../utils"

export const getCollection = (url) => (dispatch) => {

    dispatch({
        type: Constants.GETTING_COLLECTION_BY_URL
    })

    fetch(apiUrl + "/api/collection/" + url, {
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
