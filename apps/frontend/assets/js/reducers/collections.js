import Constants from "../constants"

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
                (collection, index) => {
                    if (collection.data.collection.id === action.payload.id) {
                        return {
                            data: {
                                ...collection.data,
                                ...action.payload
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.EDIT_COLLECTION_TITLE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        return {
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    title: action.payload
                                }
                            },
                            channel: collection.channel
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
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    published: true
                                }
                            },
                            channel: collection.channel
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
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    tags: collection.data.collection.tags.concat(action.payload.tag)
                                }
                            },
                            channel: collection.channel
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
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    tags: collection.data.collection.tags.filter(tag => tag !== action.payload.tag)
                                }
                            },
                            channel: collection.channel
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
                            data: {
                                ...collection.data,
                                color: action.color
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.EDIT_COLLECTION_NOTES:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        let notes = collection.data.collection.notes

                        return {
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    notes: {
                                        ...collection.data.collection.notes,
                                        body: action.payload
                                    }
                                }
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.ADD_COLLECTION_NOTE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        return {
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    notes: action.payload
                                }
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.ADD_CURRENT_COLLECTION_NOTE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        return {
                            data: {
                                ...collection.data,
                                currentCollectionNote: action.payload
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.CLEAR_CURRENT_COLLECTION_NOTE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        return {
                            data: {
                                ...collection.data,
                                currentCollectionNote: ""
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.MOVE_COLLECTION:

        let orig_collections = state.collections
        const collection_to_move = orig_collections[action.payload.oldIndex]

        orig_collections.splice(action.payload.oldIndex, 1)
        orig_collections.splice(action.payload.newIndex, 0, collection_to_move)

        return {
            ...state,
            collections: orig_collections
        }

    case Constants.ADD_RESOURCE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.payload.collection_id) {
                        let newResource = {
                            ...action.payload.data
                        }

                        return {
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: [...collection.data.collection.resources, newResource]
                                }
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }
    case Constants.EDIT_RESOURCE:
        // console.log(action.payload)
        return {
            ...state,
            collections: state.collections.map(
                (collection) => {
                    if (collection.data.collection.id === action.payload.collection_id) {
                        return {
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
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }
    case Constants.MOVE_RESOURCE:
        let originalResource = state.collections.map(
            (collection, index) => {
                if (collection.data.collection.id === action.payload.source_collection_id) {
                    return collection.data.collection.resources.filter(resource => resource.id === action.payload.resource_id)
                }
            }
        )

        let filteredOR = originalResource.filter(n => {
            return n != undefined
        })

        let collectionsFilter = state.collections.map(
            (collection, index) => {
                if (collection.data.collection.id === action.payload.source_collection_id) {
                    return {
                        data: {
                            ...collection.data,
                            collection: {
                                ...collection.data.collection,
                                resources: collection.data.collection.resources.filter(resource => resource.id !== action.payload.resource_id)
                            }
                        },
                        channel: collection.channel
                    }
                } else {
                    return collection
                }
            }
        )

        let collectionsAdd = collectionsFilter.map(
            (collection, index) => {
                if (collection.data.collection.id === action.payload.target_collection_id) {
                    return {
                        data: {
                            ...collection.data,
                            collection: {
                                ...collection.data.collection,
                                resources: insert(collection.data.collection.resources, action.payload.index, filteredOR[0][0])
                            }
                        },
                        channel: collection.channel
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
    case Constants.REMOVE_RESOURCE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.payload.collection_id) {
                        return {
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: collection.data.collection.resources.filter(resource => resource.id !== action.payload.resource_id)
                                }
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.SAVE_TO_INBOX:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.inbox_id) {
                        let newResource = {
                            ...action.payload
                        }

                        return {
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: [...collection.data.collection.resources, newResource]
                                }
                            },
                            channel: collection.channel
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
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: resources
                                }
                            },
                            channel: collection.channel
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
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: resources
                                }
                            },
                            channel: collection.channel
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
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: resources
                                }
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.EDIT_RESOURCE_NOTES:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        let resources = collection.data.collection.resources.map((resc, index) => {
                            if (resc.id === action.resource_id) {
                                return {
                                    ...resc,
                                    notes: {
                                        ...resc.notes,
                                        body: action.payload
                                    }
                                }
                            } else {
                                return resc
                            }
                        })

                        return {
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: resources
                                }
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.ADD_RESOURCE_NOTE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {

                    if (collection.data.collection.id === action.collection_id) {
                        let resources = collection.data.collection.resources.map((resc, index) => {
                            if (resc.id === action.resource_id) {
                                return {
                                    ...resc,
                                    notes: action.payload
                                }
                            } else {
                                return resc
                            }
                        })

                        return {
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: resources
                                }
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.ADD_CURRENT_RESOURCE_NOTE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        let resources = collection.data.collection.resources.map((resc, index) => {
                            if (resc.id === action.resource_id) {
                                return {
                                    ...resc,
                                    currentCollectionNote: action.payload
                                }
                            } else {
                                return resc
                            }
                        })

                        return {
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: resources
                                }
                            },
                            channel: collection.channel
                        }
                    } else {
                        return collection
                    }
                }
            )
        }

    case Constants.CLEAR_CURRENT_RESOURCE_NOTE:
        return {
            ...state,
            collections: state.collections.map(
                (collection, index) => {
                    if (collection.data.collection.id === action.collection_id) {
                        let resources = collection.data.collection.resources.map((resc, index) => {
                            if (resc.id === action.resource_id) {
                                return {
                                    ...resc,
                                    currentCollectionNote: ""
                                }
                            } else {
                                return resc
                            }
                        })

                        return {
                            data: {
                                ...collection.data,
                                collection: {
                                    ...collection.data.collection,
                                    resources: resources
                                }
                            },
                            channel: collection.channel
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
                                },
                                channel: collection.channel
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
                                data: {
                                    ...collection.data,
                                    collection: {
                                        ...collection.data.collection,
                                        files: collection.data.collection.files.concat(action.payload.file)
                                    }
                                },
                                channel: collection.channel
                            }
                        } else {
                            return collection
                        }
                    }
                )
            }
        }

    case Constants.FILE_DELETE:
        // console.log(action)
        if (action.payload.resource_id) {
            return {
                ...state,
                collections: state.collections.map(
                    (collection) => {
                        if (collection.data.collection.id === action.payload.collection_id) {
                            return {
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
                                },
                                channel: collection.channel
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
                                data: {
                                    ...collection.data,
                                    collection: {
                                        ...collection.data.collection,
                                        files: collection.data.collection.files.filter(file => file.id !== action.payload.file_id)
                                    }
                                },
                                channel: collection.channel
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