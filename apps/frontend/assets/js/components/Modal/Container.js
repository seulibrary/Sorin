import React, { Component } from "react"
import { connect } from "react-redux"
import PermaLinkModalPortal from "./PermaLinkModalPortal"
import ModalPortal from "./ModalPortal"
import { closeModal } from "../../actions/modal"

class Modal extends Component {
    constructor(props){
        super(props)
    }
    
    componentDidMount() {
        document.body.addEventListener("timeout", this.onClose)
        document.body.addEventListener("keydown", this.handleKeyPress)
    }

    componentWillUnMount() {
        document.body.removeEventListener("timeout", this.onClose)
        document.body.removeEventListener("keydown", this.handleKeyPress)
    }
    
    handleKeyPress = (e) => {
        if (e.keyCode == 27) {
            this.onClose()
        }
    }

    handleClick = (e) => {
        if ( e.target.classList.contains("window-close") || e.target.classList.contains("window-wrapper") || e.target.classList.contains("action-modal") || e.target.classList.contains("button-title")) {
            e.preventDefault()
            this.onClose()
        }
    }

    onClose = () => {
        if(this.props.item.onClose){
            this.props.item.onClose()
            this.props.onClose(this.props.item)
        } else {
            this.props.onClose(this.props.item)
        }
    }

    onConfirm = () => {
        if(this.props.item.onConfirm){
            this.props.item.onConfirm()
            this.props.onClose(this.props.item)
        }
    }

    cancelButton = input => {
        if (input) {
            setTimeout(() => {
                input.focus()
            }, 100)
        }
    }

    render() {
        const { type } = this.props.item

        if (type === "confirmation") {
            const { text, buttonText } = this.props.item

            return (
                <div className="window-wrapper confirmation" onClick={this.handleClick}>
                    <div className="window">
                        <div className="text">{text}</div>
                        <div className="buttons">
                            <button tabIndex="-1" className="btn modal-button confirm" onClick={this.onConfirm}>{buttonText ? buttonText[0] : "Confirm"}</button>
                            <button tabIndex="0" className="btn modal-button close" ref={this.cancelButton} onClick={this.onClose}>{buttonText ? buttonText[1] : "Cancel"}</button>
                        </div>
                    </div>
                </div>
            )
        } else if (type === "alert") {
            const { text, message, buttonText } = this.props.item

            return (
                <div className="window-wrapper confirmation" onClick={this.handleClick}>
                    <div className="window">
                        <div className="alert text">
                            <h4>{text}</h4>
                            <div>{message}</div>
                        </div>
                        <div className="buttons">
                            <button tabIndex="0" className="btn modal-button close" onClick={this.onClose}>{buttonText ? buttonText[0] : "OK"}</button>
                        </div>
                    </div>
                </div>
            )
        } else if (type === "custom") {
            const { content } = this.props.item
            
            return (
                <div className="window-wrapper" onClick={this.handleClick}>
                    <div className="window">
                        <button className="window-close" onClick={this.onClose}>&times;</button>
                        {content}
                    </div>
                </div>
            )
        }
        return (null)
    }
}

class Modals extends Component {
    constructor(props) {
        super(props)
    }

    render() {
        const modals = this.props.modals.modals.map((item,i) => {
           
                return <ModalPortal key={i} ><Modal item={item} onClose={(item) => this.props.dispatch(closeModal(item))}/></ModalPortal>

        })

        return (
            <div className="modals">
                {modals}
            </div>
        )
    }
}

const ModalContainer = connect(
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
)(Modals)

export default ModalContainer