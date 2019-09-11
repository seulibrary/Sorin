import React, { Component } from "react"
import Accordion from "../Accordion"
import Citation from "../Citation"
import { CirclePicker } from "react-color"
import Dropzone from "react-dropzone"
import Loader from "../Loader"
import RichTextEditor from "../RichTextEditor"
import Tags from "../Tags"
import { connect } from "react-redux"
import { openModal, closeModal } from "../../actions/modal"
import {
    addCollectionTag,
    deleteCollectionTag,
    shareCollection
} from "../../actions/collections"
import { 
    uploadFile, 
    downloadFile, 
    deleteFile, 
    fileStatusReset 
} from "../../actions/files"
import { googleExport } from "../../actions/export"
import Constants from "../../constants"
import { siteUrl, uuidv4 } from "../../utils"

class EditCollection extends Component {
    constructor(props) {
        super(props)
    }

    onTitleChange = (e) => {
        this.props.dispatch({
            type: Constants.EDIT_COLLECTION_TITLE,
            collection_id: this.props.id,
            payload: e.target.value
        })
    }

    handleMakePublic = () => {
        this.props.dispatch(
            openModal({
                id: uuidv4,
                type: "confirmation",
                panel: "collection",
                onConfirm: () => {
                    this.props.dispatch({
                        type: Constants.EDIT_COLLECTION_PUBLISH,
                        collection_id: this.props.id
                    })
                },
                text: "Are you sure you want to publish this collection? Once published, it can be deleted, but not unpublished."
            })
        )
    }

    onNoteChange = (id, content) => {
        if (!id) {
            this.props.dispatch({
                type: Constants.ADD_CURRENT_COLLECTION_NOTE,
                collection_id: this.props.id,
                payload: content
            })
        }

        if (id) {
            this.props.dispatch({
                type: Constants.EDIT_COLLECTION_NOTES,
                collection_id: this.props.id,
                note_id: id,
                payload: content
            })
        }
    }

    onTagsChange = (tags, changed) => {
        let addOrDelete = tags.indexOf(changed[0])

        if (addOrDelete != -1) {
            // save tag
            addCollectionTag(this.props.channel, this.props.id, changed[0])
        }

        if (addOrDelete === -1) {
            // delete tag
            deleteCollectionTag(this.props.channel, this.props.id, changed[0])
        }
    }

    handleChangeComplete = color => {
        this.props.dispatch({
            type: Constants.EDIT_COLLECTION_COLOR,
            collection_id: this.props.id,
            color: color.hex
        })
    }

    onDrop = (acceptedFiles, rejectedFiles) => {
        if (rejectedFiles.length === 0) {
            this.props.dispatch(
                uploadFile(
                    this.props.channel,
                    "collection",
                    this.props.id,
                    null,
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

        downloadFile(e.currentTarget.dataset.id)
    }

    removeFile = e => {
        this.props.dispatch(
            deleteFile(
                this.props.channel,
                e.currentTarget.dataset.id
            ))
    }

    handleSubmit = e => {
        e.preventDefault()

        this.props.dispatch(
            closeModal({
                id: this.props.modalId
            })
        )
    }

    componentWillUnmount() {
        let collectionData = this.props.collections.collections.find(
            collection => collection.data.collection.id === this.props.id
        )

        collectionData.channel.push("edit_collection", collectionData.data)

        this.props.dispatch({
            type: Constants.CLEAR_CURRENT_COLLECTION_NOTE,
            collection_id: this.props.id
        })
    }

    handleDeleteCollection = e => {
        e.preventDefault()

        let collectionData = this.props.collections.collections.find(
            collection => collection.data.collection.id === this.props.id
        )
        const deleteModalId = uuidv4()
        let message = ""

        if (collectionData.data.write_access == false) {
            message =
                "Are you sure you want to remove this collection from your dashboard?"
        } else {
            message =
                "Deleting this collection will remove access to it from all co-authors and cloners and cannot be undone. Would you still like to delete it?"
        }

        this.props.dispatch(
            openModal({
                id: deleteModalId,
                type: "confirmation",
                panel: "collection",
                onConfirm: () => {
                    this.confirmDeleteCollection(collectionData)
                },
                text: <div>{message}</div>
            })
        )
    }

    confirmDeleteCollection = data => {
        this.props.dispatch(
            closeModal({
                id: this.props.modalId
            })
        )
        this.props.session.dashboardChannel.push("remove_collection", {
            collection_id: this.props.id
        })
        data.channel.leave()
    }

    exportToGoogle = e => {
        e.preventDefault()

        let collectionData = this.props.collections.collections.find(
            collection => collection.data.collection.id === this.props.id
        )

        this.props.dispatch(googleExport(collectionData.channel, collectionData))
    }

    shareCollection = () => {

        this.props.dispatch(shareCollection(collection_id, user_id))
    }

    findUser = () => {
        
    }

    render() {
        let collectionData = this.props.collections.collections.find(
            collection => collection.data.collection.id === this.props.id
        )
        let data = collectionData.data
        let showFiles = data.collection.hasOwnProperty("files")

        return (
            <div className="collection-form">
                <form
                    ref={form => (this.formEl = form)}
                    onSubmit={this.handleSubmit}
                    encType="multipart/form-data"
                >
                    <div className="container">
                        <div className="window-left">
                            {this.props.index === 0 && (
                                <div>
                                    <h3>{data.collection.title}</h3>
                                </div>
                            )}

                            {this.props.index != 0 && (
                                <div>
                                    <label>Title</label>

                                    {data.write_access ? (
                                        <input
                                            onChange={this.onTitleChange}
                                            className="full-width"
                                            name="title"
                                            value={data.collection.title}
                                            type="text"
                                        />
                                    ) :
                                     <h3>{data.collection.title}</h3>
                                    }
                                </div>
                            )}

                            <label>Notes</label>

                            <RichTextEditor
                                key={data.collection.notes != null ? data.collection.notes.id : ""}
                                id={data.collection.notes != null ? data.collection.notes.id : ""}
                                onChange={this.onNoteChange}
                                data={
                                data.collection.notes != null
                                ? data.collection.notes.body
                                : ""
                                }
                                writeAccess={data.write_access}
                            />

                            {this.props.index != 0 && (
                                <div>
                                    <label>Tags</label>
                                    <Tags
                                        data={data.collection.tags || []}
                                        onChange={this.onTagsChange}
                                        disabled={!data.write_access}
                                    />
                                    <Accordion title="View Citations">
                                        <Citation data={data.collection.resources} />
                                    </Accordion>

                                    {data.collection.provenance ? (
                                        <Accordion title="View Provenance">
                                            <div>
                                                <p>{data.collection.provenance}</p>
                                            </div>
                                        </Accordion>
                                    ) : ""
                                    }
                                </div>
                            )}
                        </div>

                        <div className="window-right">
                            {this.props.index != 0 && (
                                <Accordion title="Share">
                                    {data.write_access ? (
                                        <div>
                                            {data.collection.published ?
                                             <div>
                                                 <label className="makepublic sub-title">Published
                                                     <br />
                                                     <span className="make-public-small">
                                                         A published collection is findable from the search bar, where other users will be able to view, clone, or import them. Publishing cannot be undone.
                                                     </span>
                                                 </label>
                                             </div>
                                            :
                                             <div>
                                                 <label className="makepublic inline" htmlFor="makepublic">
                                                     Publish: <input
                                                                  type="checkbox"
                                                                  id="makepublic"
                                                                  className="make-public-checkbox"
                                                                  onChange={this.handleMakePublic}
                                                                  checked={data.collection.published}
                                                     />
                                                     <br />
                                                     <span className="make-public-small">
                                                         Publishing makes collections findable from the search bar, where other users will be able to view, clone, or import them. Publishing cannot be undone.
                                                     </span>
                                                 </label>
                                             </div>
                                            }
                                        </div>
                                    ) :
                                     <div>
                                         <label className="makepublic sub-title">Published
                                             <br />
                                             <span className="make-public-small">
                                                 A published collection is findable from the search bar, where other users will be able to view, clone, or import them. Publishing cannot be undone.
                                             </span>
                                         </label>
                                     </div>
                                    }

                                    <label>
                                        <a
                                            href={"/c/" + data.collection.permalink}
                                            target="_blank"
                                            rel="noopener"
                                        >
                                            PermaLink
                                        </a>
                                    </label>
                                    <input
                                        className="add-text exp close full-width"
                                        type="text"
                                        readOnly={true}
                                        value={siteUrl + "/c/" + data.collection.permalink}
                                    />
                                    
                                    <label className="sub-title">Export Options</label>
                                    
                                    <div className="export">
                                        { this.props.exportData.exporting ? 
                                          <Loader text={"Uploading File..."} isVisible={true} /> : 
                                          <p onClick={this.exportToGoogle}>Save to Google Drive</p> }
                                    </div>
                                </Accordion>
                            )}

                            <Accordion title="Collection Color">
                                <CirclePicker
                                    width={"100%"}
                                    colors={[
                                        "#fbc3bf",
                                        "#e2a0b7",
                                        "#f0baf9",
                                        "#ccb4f7",
                                        "#b7c0f5",
                                        "#a8d6fb",
                                        "#c7e8f7",
                                        "#c5eff5",
                                        "#78f7eb",
                                        "#b0f3b3",
                                        "#cef79f",
                                        "#f2fb98",
                                        "#ffeb3b",
                                        "#f9c732",
                                        "#f7bf6e",
                                        "#f59374",
                                        "#c7d8e0",
                                        "#d8d8d8"
                                    ]}
                                    onChangeComplete={this.handleChangeComplete}
                                />
                            </Accordion>
                            
                            <i className={data.collection.files.length > 0 ? "attach" : "" }></i>
                            {this.props.index != 0 && showFiles ? (
                                <Accordion title="Attachments" >
                                	  
                                    {data.collection.files.length == 0 && !this.props.files.uploadingFile && data.write_access ? (
                                        <Dropzone maxSize={200000000} multiple={false} onDrop={this.onDrop} className={"file-drop"}>
                                            <p>
                                                Try dropping a file here, or click to select a file to
                                                upload. (Max size: 200mb)
                                            </p>
                                        </Dropzone>
                                    ) : ""}

                                    <Loader text={"Uploading File..."} isVisible={this.props.files.uploadingFile} />
                                    
                                    <ul className={"file-list"}>
                                        {data.collection.files.map((f, index) => (
                                            <li key={index}>
                                                <span
                                                	  className="filename"
                                                    title={f.size + " Bytes - Click to download attachment"}
                                                    onClick={this.downloadFile}
                                                    data-id={f.uuid}
                                                    
                                                >
                                                    {f.title}
                                                </span>
                                                { data.write_access ?
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
                                </Accordion>
                            ) : ""}
                        </div>
                    </div>
                    <div className="controls">
                        <button className="btn save" type="submit">
                            Save
                        </button>

                        {this.props.index != 0 && (
                            <button
                                className="btn delete"
                                onClick={this.handleDeleteCollection}
                            >
                                {data.write_access ? "Delete" : "Remove"}
                            </button>
                        )}
                    </div>
                </form>
            </div>
        )
    }
}

export default connect(
    function mapStateToProps(state) {
        return {
            collections: state.collections,
            session: state.session,
            exportData: state.exportData,
            files: state.files,
            settings: state.settings
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(EditCollection)
