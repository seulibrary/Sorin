import React, { Component } from "react"
import { connect } from "react-redux"
import Citation from "../Citation"
import Accordion from "../Accordion"
import { removeResource, editResource } from "../../actions/collections"
import Dropzone from "react-dropzone"
import Loader from "../Loader"
import Form from "../Form"
import RichTextEditor from "../RichTextEditor"
import { uuidv4 } from "../../utils"
import { 
    uploadFile, 
    downloadFile, 
    deleteFile,
    fileStatusReset
} from "../../actions/files"
import { openModal, closeModal } from "../../actions/modal"
import Constants from "../../constants"

class EditResource extends Component {
    constructor(props) {
        super(props)

        this.state = {
            deleting: false
        }

        this.resourceRef = React.createRef()
    }

    onTitleChange = e => {
        this.props.dispatch({
            type: Constants.EDIT_RESOURCE_TITLE,
            collection_id: this.props.parent,
            resource_id: this.props.id,
            title: e.target.value
        })
    }

    onDrop = (acceptedFiles, rejectedFiles) => {
        if (rejectedFiles.length === 0) {
            this.props.dispatch(
                uploadFile(
                    this.props.channel,
                    "resource",
                    this.props.parent,
                    this.props.id,
                    acceptedFiles[0]
                )
            )
        } else {
            this.props.dispatch(
                openModal({
                    id: uuidv4,
                    type: "alert",
                    panel: "collection",
                    text: "Error: " + rejectedFiles[0].name + " was not uploaded.",
                    message: "Max file size per upload 200mb."
                })
            )

            this.props.dispatch(fileStatusReset())
        }
    }

    downloadFile = e => {
        e.preventDefault()
        downloadFile(e.currentTarget.dataset.id, this.props.settings.api_port)
    }

    removeFile = e => {
        this.props.dispatch(
            deleteFile(
                this.props.channel,
                e.currentTarget.dataset.id,
                this.props.parent
            ))
    }

    onUrlChange = e => {
        this.props.dispatch({
            type: Constants.EDIT_RESOURCE_URL,
            collection_id: this.props.parent,
            resource_id: this.props.id,
            url: e.target.value
        })
    }

    onTypeChange = (value) => {
        this.props.dispatch({
            type: Constants.EDIT_RESOURCE_TYPE,
            collection_id: this.props.parent,
            resource_id: this.props.id,
            payload: value
        })
    }

    onNoteChange = (id, content) => {
        if (!id) {
            this.props.dispatch({
                type: Constants.ADD_CURRENT_RESOURCE_NOTE,
                collection_id: this.props.parent,
                resource_id: this.props.id,
                payload: content
            })
        }

        if (id) {
            this.props.dispatch({
                type: Constants.EDIT_RESOURCE_NOTES,
                collection_id: this.props.parent,
                resource_id: this.props.id,
                note_id: id,
                payload: content
            })
        }
    }

    handleResourceDelete = e => {
        e.preventDefault()

        const deleteModalId = uuidv4()

        const message =
            "Deleting this resource will remove access to it from all co-authors and cloners and cannot be undone. Would you still like to delete it?"

        this.props.dispatch(
            openModal({
                id: deleteModalId,
                type: "confirmation",
                panel: "collection",
                onConfirm: () => {
                    this.confirmDeleteResource()
                },
                text: <div>{message}</div>
            })
        )
    }

    confirmDeleteResource = () => {
        this.setState({
            deleting: true
        }, () => {
            this.props.dispatch(
                closeModal({
                    id: this.props.modalId
                })
            )
            removeResource(
                this.props.channel,
                this.props.parent,
                this.props.id
            )
        })
    }

    componentWillUnmount() {
        // check state to make sure we don't try to edit something we are deleting
        if (this.state.deleting === false) {
            if (this.props.canEdit != false) {
                let resourceData

                this.props.collections.collections.map(collection => {
                    if (collection.data.collection.id === this.props.parent) {
                        resourceData = collection.data.collection.resources.find(
                            resource => resource.id === this.props.id
                        )
                    }
                })

                // save data
                editResource(
                    this.props.channel,
                    this.props.parent,
                    resourceData
                )
            }
            // clear out temp note field.
            this.props.dispatch({
                type: Constants.CLEAR_CURRENT_RESOURCE_NOTE,
                collection_id: this.props.parent,
                resource_id: this.props.id
            })
        }
    }

    handleSubmit = () => {
        if (this.props.canEdit != false) {
            this.props.dispatch(closeModal({
                id: this.props.modalId
            }))
        }
    }

    render() {        
        let collectionData = this.props.collections.collections.find(
            collection => collection.data.collection.id === this.props.parent
        )
        let data = {}

        if (this.props.hasOwnProperty("data")) {
            data = this.props.data
        } else {
            data = collectionData.data.collection.resources[this.props.index]
        }

        let notes = data.notes
        let disabled =
            data.identifier || this.props.canEdit == false
                ? { readOnly: true }
                : {}
        let showFiles = this.props.showFiles === false ? false : true
  
        return (
            <Form
                submit={this.handleSubmit}
                className="resource-form"
                ref={this.resourceRef}
            >
                <div className="container">
                    <div className="resource-column-left">
                        <div
                            className={"resource-box-icon icon " + data.type}
                        />
                        
                        {data.catalog_url && (
                            <a
                                title="Go To Link"
                                className="resource-box-link"
                                target="_blank"
                                href={ 
                                    !data.catalog_url.match(/^[a-zA-Z]+:\/\//) ?
                                        "//" + data.catalog_url : data.catalog_url }
                            >
                                OPEN
                            </a>
                        )}
                    </div>

                    <div className="resource-column-middle">
                        <label>
                            <div
                                className={"mobile-only resource-box-icon icon " + data.type}
                            />
                            
                            Title
                            
                            {data.catalog_url && (
                                <a
                                    title="Go To Link"
                                    className="mobile-only resource-box-link"
                                    target="_blank"
                                    href={ 
                                        !data.catalog_url.match(/^[a-zA-Z]+:\/\//) ?
                                            "//" + data.catalog_url : data.catalog_url }
                                >
                                OPEN
                                </a>
                            )}
                        </label>
                        
                        { this.props.canEdit ? 
                            <input
                                type="text"
                                required={true}
                                name="title"
                                {...disabled}
                                className="full-width resource-title"
                                placeholder="Resource Title"
                                defaultValue={data.title}
                                onChange={this.onTitleChange}
                            />
                            :
                            <span className={"full-width resource-title"}>
                                {data.title}
                            </span>
                        }

                        <label>Notes</label>

                        <RichTextEditor
                            key={notes != null ? notes.id : ""}
                            id={notes != null ? notes.id : ""}
                            onChange={this.onNoteChange}
                            data={notes != null ? notes.body : ""}
                            writeAccess={this.props.canEdit}
                        />

                        {data.description && (
                            <Accordion
                                title={"Description"}
                                titleClass={"more-info"}
                            >
                                <div>{data.description}</div>
                            </Accordion>
                        )}

                        {data.identifier && (
                            <Accordion
                                title={"Item URL"}
                                titleClass={"more-info"}
                            >
                                <input
                                    type="text"
                                    className="full-width"
                                    readOnly={true}
                                    name="url"
                                    placeholder="Item URL"
                                    value={data.catalog_url}
                                />
                            </Accordion>
                        )}

                        {!data.identifier && (
                            <Accordion
                                title={"Item URL"}
                                titleClass={"more-info"}
                            >
                           
                                <input
                                    type="text"
                                    className="full-width"
                                    {...disabled}
                                    name="url"
                                    placeholder="Item URL"
                                    defaultValue={data.catalog_url}
                                    onChange={this.onUrlChange}
                                />
                            </Accordion>
                        )}

                        <Accordion title={"Citations"} titleClass={"more-info"}>
                            <Citation data={data} />
                        </Accordion>
                    </div>

                    <div className="resource-column-right">
                        {showFiles ? (
                            <React.Fragment>
                                <i className={data.files.length > 0 ? "attach" : "" }></i>
                                <Accordion title="Attachment">
                                    <div>
                                        {data.files.length == 0 && !this.props.files.uploadingFile && this.props.canEdit ? (
                                            <Dropzone maxSize={200000000} multiple={false} onDrop={this.onDrop} className={"file-drop"}>
                                                <p>
                                            Try dropping a file here, or click to select a file to
                                            upload. (Max size: 200mb)
                                                </p>
                                            </Dropzone>
                                        ) : ""}
                                    
                                        <Loader text={"Uploading File..."} isVisible={this.props.files.uploadingFile} />
                                    
                                        <ul className={"file-list"}>
                                            {data.files.map((f, index) => (
                                                <li key={index}>
                                                    <span
                                                        title={f.size + " Bytes"}
                                                        onClick={this.downloadFile}
                                                        data-id={f.uuid}
                                                        className="filename"
                                                    >
                                                        {f.title}
                                                    </span>
                                                    { this.props.canEdit ?
                                                        <React.Fragment>
                                                        &nbsp;
                                                            <span className={"delete"} onClick={this.removeFile} data-id={f.uuid} title="Delete File">
                                                        &times;
                                                            </span>
                                                        </React.Fragment>
                                                        :
                                                        ""
                                                    }
                                                </li>
                                            ))}
                                        </ul>
                                    </div>
                                </Accordion>
                            </React.Fragment>
                        ) : ""}
                    </div>
                </div>

                <div className="controls">
                    {this.props.canEdit != false && (
                        <div className="controls">
                            <button className="btn create" type="submit">
                                Save
                            </button>

                            <button
                                className="btn delete"
                                onClick={this.handleResourceDelete}
                            >
                                Delete
                            </button>
                        </div>
                    )}
                </div>
            </Form>
        )
    }
}

export default connect(
    function mapStateToProps(state) {
        return {
            session: state.session,
            collections: state.collections,
            files: state.files,
            settings: state.settings
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(EditResource)
