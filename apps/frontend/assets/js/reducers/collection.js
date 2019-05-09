import Constants from "../constants"

const initialState = {
    collection: {},
    collectionLoading: false,
}

const collection = (state = initialState, action) => {
    switch (action.type) {
    case Constants.GETTING_COLLECTION_BY_URL:
        return {
            collection: {},
            collectionLoading: true
        }
    case Constants.GET_COLLECTION_BY_URL:
        return {
            collection: action.payload,
            collectionLoading: false
        }
    default:
        return state
    }
}

export default collection