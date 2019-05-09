import React, {Component} from "react"
import { connect } from "react-redux"
import ReactHtmlParser from "react-html-parser"
import {openModal} from "../../actions/modal"
import {uuidv4} from "../../utils"

class Notice extends Component {
    componentDidMount() {
        this.notice()
    }

    notice = () => {
        const containerLoaded = document.getElementById("main")
        
        if (window.flashError && containerLoaded) {
            const editErrorModalId = uuidv4()
            
            this.props.dispatch(openModal({
                id: editErrorModalId,
                type: "custom",
                panel: "search",
                content: this.infoModal(window.flashError, editErrorModalId),
            }))
        }

        if (window.flashInfo && containerLoaded) {
            const editInfoModalId = uuidv4()

            this.props.dispatch(openModal({
                id: editInfoModalId,
                type: "custom",
                panel: "search",
                content: this.errorModal(window.flashInfo, editInfoModalId),
            }))
        }
        
        return null
    }

    infoModal = (text, id) => {
        return  React.createElement("div",{className: "info-modal"},<p>{ReactHtmlParser(text)}</p>)
    }

    errorModal = (text, id) => {
        return  React.createElement("div",{className: "error-modal"},<p>{ReactHtmlParser(text)}</p>)
    }

    render () {
        // return null because we only want to render or do anything until the component is loaded. Also, we are using Modals for the notice, which use portals.
        return (null)
    }
}

export default connect(
    function mapStateToProps(state) {
        return {
            modals: state.modals
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(Notice)