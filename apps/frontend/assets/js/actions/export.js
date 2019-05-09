import Constants from "../constants"
import store from "../store"

export const googleExport = (channel, collection_data) => {
    return (dispatch) => {

        dispatch({
            type: Constants.EXPORT_COLLECTION,
            payload: collection_data
        })

        let data = store.getState().exportData

        channel.push("google_export", {
            collection_data: data
        }).receive(
            "ok", resp => {
                dispatch({
                    type: Constants.RESET_EXPORT_COLLECTION
                })
            }
        )
    }
}