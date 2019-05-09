import React, { Component } from "react"
import { connect } from "react-redux"
import Form from "../Form"
import { createResource } from "../../actions/collections"
import { closeModal } from "../../actions/modal"
import PropTypes from "prop-types"

class NewResource extends Component {
    constructor(props) {
        super(props)
        this.state = {
            title: "",
            catalog_url: "",
            author: "",
            publication_date: ""
        }
    }

    onChange = e => {
        const data = this.state

        data[e.target.name] = e.target.value

        this.setState(data)
    }

    handleSubmit = () => {
        createResource(this.props.channel, this.props.parent, this.state)

        this.setState({
            title: "",
            url: "",
            author: "",
            publication_date: ""
        })

        this.props.dispatch(
            closeModal({
                id: this.props.modalId
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
        return (
            <div className="new-resource-form">
                <Form submit={this.handleSubmit}>
                    <div className="container">
                        <h3>New Custom Resource</h3>

                        <label>
                            Title<span className="required">*</span>
                        </label>
                        <input
                            type="text"
                            required={true}
                            ref={this.focusInputField}
                            name="title"
                            className="full-width"
                            placeholder="Item Name"
                            onChange={this.onChange}
                        />

                        <label>Item URL</label>
                        <input
                            type="text"
                            name="catalog_url"
                            className="full-width"
                            placeholder="Item URL"
                            onChange={this.onChange}
                        />
                    </div>
                    <div className="controls">
                        <button className="btn create" id="" type="submit">
                            Create
                        </button>
                    </div>
                </Form>
            </div>
        )
    }
}

NewResource.propTypes = {
    title: PropTypes.string,
    url: PropTypes.string,
    author: PropTypes.string,
    publication_date: PropTypes.string
}

export default connect(
    function mapStateToProps(state) {
        return {
            collections: state.collections
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(NewResource)
