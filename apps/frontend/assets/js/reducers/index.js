import {combineReducers} from "redux"
import { routerReducer } from "react-router-redux"
import session from "./sessions"
import modals from "./modals"
import accordions from "./accordions"
import collection from "./collection"
import collections from "./collections"
import search from "./search"
import searchFilters from "./searchFilters"
import files from "./files"
import exportData from "./exportData"
import extensions from "./extensions"
import settings from "./settings"
import notifications from "./notifications"

export default combineReducers({
    session,
    files,
    search, 
    searchFilters,
    accordions, 
    modals,
    collection,
    collections,
    exportData,
    extensions,
    settings,
    notifications,
    routing: routerReducer
})