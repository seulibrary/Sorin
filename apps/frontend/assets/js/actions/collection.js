import Constants from "../constants"
import { apiUrl, parseJSON } from "../utils"

export const getCollection = (url) => (dispatch) => {

    dispatch({
        type: Constants.GETTING_COLLECTION_BY_URL
    })

<<<<<<< HEAD
    fetch(apiUrl + "/api/collection/" + url, {
        method: "GET",
        credentials: "same-origin"
    }).then(parseJSON)
=======
    fetch(hostUrl + ":" + port + "/api/collection/" + url, {
        method: "GET",
    }).then(parseJson)
>>>>>>> 99cc54d... convert api/collection to GET and use built-in resources to define functions called in controller.
        .then((json) => {
            dispatch({
                type: Constants.GET_COLLECTION_BY_URL,
                payload: json
            })
        })
}
