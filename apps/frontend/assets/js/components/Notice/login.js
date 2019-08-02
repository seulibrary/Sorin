import React, { Component } from "react"
import { connect } from "react-redux"
import { openModal } from "../../actions/modal"
import { uuidv4 } from "../../utils"

class LoginNotice extends Component {
    componentDidMount() {
        this.renderModal()
    }

    renderModal = () => {
        let url_append = this.props.url_state ? "?state=" + JSON.stringify(this.props.url_state) : ""
        
        this.props.dispatch(
            openModal({
                id: uuidv4,
                type: "alert",
                text: <div>You need to <a href={"/auth/google" + url_append}>login</a> to use that feature.</div>
            })
        )
    }

    render() {
        return null
    }
}

export default connect(
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(LoginNotice)
