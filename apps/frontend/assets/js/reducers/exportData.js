import { stateToHTML } from "draft-js-export-html"
import { 
    EditorState, 
    ContentState, 
    convertFromRaw 
} from "draft-js"
import Constants from "../constants"

const initialState = {
    data: {},
    exporting: false
}

const exportData = (state = initialState, action) => {
    switch (action.type) {
    case Constants.EXPORT_COLLECTION:
        let data = action.payload.data.collection

        return {
            ...state,
            exporting: true,
            data: {
                ...data,
                notes: data.notes && data.notes.body ? {...data.notes, body: formatNote(data.notes.body) } : null,
                resources: data.resources.map((resc) => {
                    if (resc.notes) {
                        return {
                            ...resc,
                            notes: {
                                ...resc.notes,
                                body: formatNote(resc.notes.body)
                            }
                        }
                    } else {
                        return resc
                    }
                })
            }
        }
    case Constants.RESET_EXPORT_COLLECTION:
        return initialState
    default:
        return state
    }
}

const formatNote = (note) => {
    let exportNote = {}

    if (isJson(note)) {
        exportNote = EditorState.createWithContent(convertFromRaw(JSON.parse(note)))
    } else if (note) {
        exportNote = EditorState.createWithContent(ContentState.createFromText(note))
    } else {
        exportNote = EditorState.createEmpty()
    }

    return stateToHTML(exportNote.getCurrentContent())
}

const isJson = (str) => {
    try {
        JSON.parse(str)
    } catch (e) {
        return false
    }
    return true
}

export default exportData