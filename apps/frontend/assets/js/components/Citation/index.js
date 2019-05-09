import React, { Component } from "react"
import Clipboard from "../Clipboard"
import Cite from "citation-js"
import mla from "./plugins/mla.js"
import chicago from "./plugins/chicago.js"

export default class Citation extends Component {
    constructor(props) {
        super(props)
        this.state = {
            copyValue: "",
            citation: "apa",
            data: this.props.data,
            copied: false
        }
    }

    componentDidMount() {
        // set default value for citation as apa
        this.setState(this.state.copyValue ? this.state.copyValue : this.whichCitation("apa"))
    }

    handleChange = (e) => {
        e.preventDefault()
        this.setState({
            copied: false
        })
        this.setState({
            citation: e.target.value
        })
        this.whichCitation(e.target.value)
    }

    onCopy = () => {
        this.setState({
            copied: true
        })
    }

    whichCitation = (type) => {
        let apa, mla, chi

        switch (type) {
        case "apa":
            apa = this.buildAPA()

            return this.setState({
                copyValue: apa
            })
        case "mla":
            mla = this.buildMLA()

            return this.setState({
                copyValue: mla
            })
        case "chicago":
            chi = this.buildCHI()

            return this.setState({
                copyValue: chi
            })
        default:
            return "error"
        }
    }

    parseCitation = (cData) => {
        let json = {}

        if (cData.call_number != null) {
            json["call-number"] = cData.call_number
        }

        let authorList = cData.creator || cData.contributor || []

        if (authorList !== []) {
            json.author = authorList
        }

        if (cData.date) {
            let date = cData.date.split("-")
            
            date = date.map(Number)

            json.issued = { "date-parts": [date] }
        }
        
        if (cData.doi != null) {
            json.DOI = cData.doi
        }

        if (cData.issue != null) {
            json.issue = cData.issue
        }

        if (cData.journal != null) {
            json["container-title"] = cData.journal
        }

        if (cData.language != null) {
            json.language = cData.language
        }

        if (cData.pages != null) {
            json.page = cData.pages
        }

        if (cData.publisher != null) {
            json.publisher = cData.publisher
        }

        if (cData.title != null) {
            json.title = cData.title
        }

        if (cData.itemtype != null) {
            let itemtype = cData.itemtype

            if (cData.itemtype == "article") {
                itemtype = "article-journal"
            }

            json.type = itemtype
        }

        if (cData.volume != null) {
            json.volume = cData.volume
        }

        return Cite.parse.csl([json])
    }

    buildAPA = () => {
        let cData = this.props.data

        if (!Array.isArray(cData)) {
            cData = [cData]
        }

        let opt = {
            format: "string",
            type: "html",
            style: "citation-apa",
            lang: "en-US"
        }

        let citationAPA = cData.map(data => {
            let cite = new Cite()
            let json = this.parseCitation(data)

            return cite.set(json).get(opt)
        })

        return citationAPA.join("")
    }

    buildMLA = () => {
        let cData = this.props.data

        Cite.CSL.register.addTemplate("mla", mla)

        if (!Array.isArray(cData)) {
            cData = [cData]
        }

        let citationMLA = cData.map(data => {
            let json = this.parseCitation(data)
            let cite = new Cite(json)

            return cite.format("bibliography", {
                format: "html",
                template: "mla"
            })
        })

        return citationMLA.join("")
    }

    buildCHI = () => {
        let cData = this.props.data

        Cite.CSL.register.addTemplate("chicago", chicago)

        if (!Array.isArray(cData)) {
            cData = [cData]
        }

        let citationCHI = cData.map(data => {
            let json = this.parseCitation(data)
            let cite = new Cite(json)

            return cite.format("bibliography", {
                format: "html",
                template: "chicago"
            })
        })

        return citationCHI.join("")
    }

    render() {
        return (
            <div className="citations">
                <div className="citation-type">
                    <label>Format:</label>
                    <select value={this.state.citation} onChange={this.handleChange}>
                        <option value="apa">APA</option>
                        <option value="chicago">Chicago</option>
                        <option value="mla">MLA</option>
                    </select>
                </div>
                <div className="citation-output">
                    <Clipboard onCopy={this.onCopy} copied={this.state.copied} value={this.state.copyValue} />
                    
                    <p>Remember to check citations for accuracy before including them in your work</p>
                </div>
            </div>
        )
    }
}