import Constants from "../constants"

const settings = importJson()

export const siteUrl = settings.url

export const apiUrl = settings.hasOwnProperty("api_url") ? settings.api_url : siteUrl

export const getSiteSettings = () => {
    return {
        type: Constants.GET_SITE_SETTINGS,
        payload: importJson()
    }
}

function importJson() {
    try {
        return require("./config.json")
    } catch (ex) {
        return {}
    }
}

export function uuidv4() {
    return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
        (
            c ^
            (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (c / 4)))
        ).toString(16)
    )
}

export function formatBytes(a, b) {
    if (0 == a) return "0 Bytes"

    var c = 1024,
        d = b || 2,
        e = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"],
        f = Math.floor(Math.log(a) / Math.log(c))

    return parseFloat((a / Math.pow(c, f)).toFixed(d)) + " " + e[f]
}

const defaultHeaders = {
    Accept: "application/json",
    "Content-Type": "application/json"
}

export function checkStatus(response) {
    if (response.ok) {
        return response
    } else {
        // var error      = {};
        // error.response = response;
        // throw error;
    }
}

export function parseJSON(response) {
    return response.json()
}

export function httpPost(url, data, headers = defaultHeaders) {
    const body = JSON.stringify(data)

    return fetch(url, {
        method: "POST",
        headers: headers,
        credentials: "same-origin",
        body: body
    })
        .then(checkStatus)
        .then(parseJSON)
}

// nothing to see here... why are you looking at me?
