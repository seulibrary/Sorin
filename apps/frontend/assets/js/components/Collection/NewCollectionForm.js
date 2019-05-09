import React, { Component } from "react"
import PropTypes from "prop-types"
import Form from "../Form"
import { connect } from "react-redux"
import { createCollection } from "../../actions/collections"
import { closeModal } from "../../actions/modal"

class NewCollectionForm extends Component {
    constructor(props) {
        super(props)
        
        this.state = {
            title: ""
        }
    }

    onChange = (e) => {
        const state = this.state

        state[e.target.name] = e.target.value

        this.setState(state)
    }

    onNoteChange = (e) => {
        this.setState({
            notes: e
        })
    }

    handleSubmit = () => {
        createCollection(this.props.session.dashboardChannel, this.state.title)

        this.props.onClose()

        this.props.dispatch(
            closeModal({
                id: this.props.id
            })
        )
    }

    focusInputField = input => {
        if (input) {
            setTimeout(() => {
                input.focus()
            }, 100)
        }
    }

    render() {
        const { title } = this.state

        return (
            <div className="new-collection-form">
                <Form submit={this.handleSubmit}>
                    <div className="container">
                        <label>Title <span className="required">*</span></label>
                        <input type="text" className="full-width" name="title" onChange={this.onChange} value={title} autoComplete="off" required={true} placeholder="Title" ref={this.focusInputField} />
                    </div>
                        
                    <div className="controls">
                        <button className="btn save" type={"submit"}>Create</button>
                    </div>
                </Form>
            </div>
        )
    }
}

NewCollectionForm.propTypes = {
    title: PropTypes.string,
}

export default connect(
    function mapStateToProps(state) {
        return {
            session: state.session,
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(NewCollectionForm)