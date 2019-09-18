import Constants from "../constants"
import { setPresence, presenceDiff } from '../actions/collections'
import { DH_UNABLE_TO_CHECK_GENERATOR } from "constants"

const initialState = {
    collections: [],
    dashboardChannel: null,
    collectionsLoading: true,
}

const collections = (state = initialState, action) => {
    switch (action.type) {
    case Constants.GETTING_DASHBOARD:
        return {
            ...state,
            collectionsLoading: true
        }

    case Constants.GOT_DASHBOARD:
        return {
            ...state,
            collectionsLoading: false
        }

    case Constants.ADD_COLLECTION_TO_DASHBOARD:
        // check to make sure collection does not already exist
        let exists = state.collections.some((el) => {
            return el.data.collection.id === action.payload.data.collection.id
        })

        let collection_set = exists ? state.collections : state.collections.concat(action.payload)

        return {
            ...state,
            collections: collection_set
        }

    case Constants.REMOVE_COLLECTION:
        return {
            ...state,
            collections: state.collections.filter(collection => collection.data.collection.id !== action.payload.collection_id)
        }

    case Constants.EDIT_COLLECTION:
        return {
            ...state,
            collections: state.collections.map(
                (collection) => {
                    if (collection.data.collection.id === action.payload.collection.id) {
                        if (collection.data.id === action.payload.id) {
                            return {
                                ...collection,
                                data: {
                                    ...collection.data,
                                    ...action.payload
                                }
                            }
                        }

                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {...action.payload.collection}
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case "PRESENCE/SET":
        return {
            ...state,
            collections: state.collections.map(
                (collection) => {
                    if (collection.data.collection.id === parseInt(action.payload.users.metas[0].collection_id)) {
                        return {
                            ...collection,
                            presence: action.payload.users.metas,
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case "PRESENCE/DIFF":
        return {
            ...state,
            collections: state.collections.map(
                (collection) => {
                    if (collection.data.collection.id === action.collection_id) {
                        return {
                            ...collection,
                            presence: {
                                ...action.payload
                            },
                        }
                    } else {
                        return collection
                    }
                })
        }

    case Constants.EDIT_COLLECTION_TITLE:
        return {
            ...state,
            collections: state.collections.map(
                (collection) => {
                    if (collection.data.collection.id === action.collection_id) {
                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    title: action.payload
                                }
                            },
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.EDIT_COLLECTION_PUBLISH:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    published: true
                                }
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.ADD_COLLECTION_TAG:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.payload.collection_id) {
                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    tags: collection.data.collection.tags.concat(action.payload.tag)
                                }
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.REMOVE_COLLECTION_TAG:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.payload.collection_id) {
                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    tags: collection.data.collection.tags.filter(tag => tag !== action.payload.tag)
                                }
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.EDIT_COLLECTION_COLOR:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                color: action.color
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.UPDATE_COLLECTION_NOTES:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    notes: {
                                        ...action.note
                                    }
                                }
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.MOVE_COLLECTION:
        let orig_collections = state.collections

        // Confirms that the move has not happened in your brower already
        if (orig_collections[action.payload.old_index].data.collection.id == action.payload.collection_id) {
            const collection_to_move = orig_collections[action.payload.old_index]

            orig_collections.splice(action.payload.old_index, 1)
            orig_collections.splice(action.payload.new_index, 0, collection_to_move)

            return {
                ...state,
                collections: orig_collections
            }
        } else {
            return {
                ...state
            }
        }

    case Constants.ADD_RESOURCE:
        console.log("add resource")
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.payload.collection_id) {
                        let newResource = {
                            ...action.payload.data
                        }

                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: [...collection.data.collection.resources, newResource]
                                }
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.ADD_RESOURCE_BY_INDEX:
        // check the exhisting state and see if it matches what is being requested. If so, don't do it.
        if (state.collections.some(
            (collection) => {
                return collection.data.collection.resources.some(
                    (r, i) => {
                        return collection.data.collection.id == action.payload.target_collection_id && r.id === action.payload.resource_id &&
                        i === action.payload.target_index
                    })
            }
        )) {
            return {
                ...state
            }
        }
        
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.payload.target_collection_id) {
                        let newResource = action.payload.data
                        
                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    
                                    resources: insert(collection.data.collection.resources, action.payload.target_index, newResource)
                                }
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }
    case Constants.MOVE_RESOURCE:
        let orig_state = state.collections
        
        // Ger original resource that is being moved
        let originalResource = orig_state.map(
            (collection, index) => {
                if (collection.data.collection.id === action.payload.source_collection_id) {
                    return collection.data.collection.resources.filter(resource => resource.id === action.payload.resource_id)
                }
            }
        )

        // clean up the results
        let filteredOR = originalResource.filter(n => {
            return n != undefined
        })

        if (!Array.isArray(filteredOR[0]) || !filteredOR[0].length) {
            // array does not exist, is not an array, or is empty
            // ⇒ do not attempt to process any further
            return {
                ...state
            }
        }

        // if the move has already happened (i.e. this reducer has happened before the state was updated by the server.) don't do it.
        if (orig_state.some(
            (collection) => {
                collection.data.collection.id === action.payload.source_collection_id &&
                collection.data.collection.resources.some(
                    (r, i) => {
                        r.id === action.payload.resource_id &&
                        i === action.payload.target_index
                    })
            }
        )) {
            return {
                ...state
            }
        }

        // remove resource from collection
        let collectionsFilter = orig_state.map(
            (collection, index) => {
                if (collection.data.collection.id === action.payload.source_collection_id) {
                    return {
                        ...collection,
                        data: {
                            ...collection.data,
                            collection: {
                                ...collection.data.collection,
                                resources: collection.data.collection.resources.filter(resource => resource.id !== action.payload.resource_id)
                            }
                        }
                    }
                } else {
                    return collection
                }
            }
        )
        
        // add resource into collection
        let collectionsAdd = collectionsFilter.map(
            (collection, index) => {
                if (collection.data.collection.id === action.payload.target_collection_id) {
                    return {
                        ...collection,
                        data: {
                            ...collection.data,
                            collection: {
                                ...collection.data.collection,
                                resources: insert(collection.data.collection.resources, action.payload.target_index, filteredOR[0][0])
                            }
                        }
                    }
                } else {
                    return collection
                }
            }
        )

        return {
            ...state,
            collections: collectionsAdd
        }
    case Constants.EDIT_RESOURCE:
        return {
            ...state,
            collections: state.collections.map(
                (collection) => {
                    if (collection.data.collection.id === action.payload.collection_id) {
                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: collection.data.collection.resources.map(
                                        (resc) => {
                                            if (resc.id === action.payload.data.id) {
                                                return action.payload.data
                                            } else {
                                                return resc
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }
    
    case Constants.REMOVE_RESOURCE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.payload.collection_id) {
                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: collection.data.collection.resources.filter(resource => resource.id !== action.payload.resource_id)
                                }
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.EDIT_RESOURCE_TITLE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        let resources = collection.data.collection.resources.map((resc, index) => {
                            if (resc.id === action.resource_id) {
                                return {
                                    ...resc,
                                    title: action.title
                                }
                            } else {
                                return resc
                            }
                        })

                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: resources
                                }
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.EDIT_RESOURCE_URL:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        let resources = collection.data.collection.resources.map((resc, index) => {
                            if (resc.id === action.resource_id) {
                                return {
                                    ...resc,
                                    catalog_url: action.url
                                }
                            } else {
                                return resc
                            }
                        })

                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: resources
                                }
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.EDIT_RESOURCE_TYPE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        let resources = collection.data.collection.resources.map((resc, index) => {
                            if (resc.id === action.resource_id) {
                                return {
                                    ...resc,
                                    type: action.payload
                                }
                            } else {
                                return resc
                            }
                        })

                        return {
                            ...collection,
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: resources
                                }
                            }
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.UPDATE_RESOURCE_NOTES:
            return {
                ...state,
                collections: state.collections.map(
                    (collection, index) => {
                        if (collection.data.collection.id === action.collection_id) {
                            return {
                                ...collection,
                                data: {
                                    ...collection.data,
                                    collection: {
                                        ...collection.data.collection,
                                        resources: collection.data.collection.resources.map((resc, index) => {
                                            if (resc.id === action.resource_id) {
                                                return {
                                                    ...resc,
                                                    notes: {
                                                        ...action.note
                                                    }
                                                }
                                            } else {
                                                return resc
                                            }
                                        })
                                    }
                                }
                            }
                            
                        } else {
                            return collection
                        }
                    }
                )
            }
        

    case Constants.FILE_UPLOAD:
        if (action.payload.resource_id) {
            return {
                ...state,
                collections: state.collections.map(
                    (collection) => {
                        if (collection.data.collection.id === action.payload.collection_id) {
                            return {
                                ...collection,
                                data: {
                                    ...collection.data,
                                    collection: {
                                        ...collection.data.collection,
                                        resources: collection.data.collection.resources.map((resc, index) => {
                                            if (resc.id === action.payload.resource_id) {
                                                return {
                                                    ...resc,
                                                    files: resc.files.concat(action.payload.file)
                                                }
                                            } else {
                                                return resc
                                            }
                                        })
                                    }
                                }
                            }
                        } else {
                            return collection
                        }
                    })
            }
        } else {
            return {
                ...state,
                collections: state.collections.map(
                    (collection) => {
                        if (collection.data.collection.id === action.payload.collection_id) {
                            return {
                                ...collection,
                                data: {
                                    ...collection.data,
                                    collection: {
                                        ...collection.data.collection,
                                        files: collection.data.collection.files.concat(action.payload.file)
                                    }
                                }
                            }
                        } else {
                            return collection
                        }
                    }
                )
            }
        }

    case Constants.FILE_DELETE:
        if (action.payload.resource_id) {
            return {
                ...state,
                collections: state.collections.map(
                    (collection) => {
                        if (collection.data.collection.id === action.payload.collection_id) {
                            return {
                                ...collection,
                                data: {
                                    ...collection.data,
                                    collection: {
                                        ...collection.data.collection,
                                        resources: collection.data.collection.resources.map((resc, index) => {
                                            if (resc.id === action.payload.resource_id) {
                                                return {
                                                    ...resc,
                                                    files: resc.files.filter(file => file.id != action.payload.file_id)
                                                }
                                            } else {
                                                return resc
                                            }
                                        })
                                    }
                                }
                            }
                        } else {
                            return collection
                        }
                    })
            }
        } else {
            return {
                ...state,
                collections: state.collections.map(
                    (collection) => {
                        if (collection.data.collection.id === action.payload.collection_id) {
                            return {
                                ...collection,
                                data: {
                                    ...collection.data,
                                    collection: {
                                        ...collection.data.collection,
                                        files: collection.data.collection.files.filter(file => file.id !== action.payload.file_id)
                                    }
                                }
                            }
                        } else {
                            return collection
                        }
                    }
                )
            }
        }
    default:
        return state
    }
}

const insert = (arr, index, newItem) => [
    // part of the array before the specified index
    ...arr.slice(0, index),
    // inserted item
    newItem,
    // part of the array after the specified index
    ...arr.slice(index)
]

const elementPos = (array, id) => {
    return array.map(function (x) {
        return x.id
    }).indexOf(id)
}

export default collections
