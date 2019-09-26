import React, { Component } from "react"
import { connect } from "react-redux"
import { Droppable, Draggable } from "react-beautiful-dnd"
import { EditCollection } from "../Collection"
import { Resource, NewResource } from "../CollectionResource"
import { openModal } from "../../actions/modal"
import { uuidv4 } from "../../utils"
import {resolveCollectionShare} from "../../actions/collections"
class Collection extends Component {
    acceptShare = () => {
        let collectionData = this.props.collections.collections.find(
            (collection) => collection.data.collection.id === this.props.id
        )
        
        this.props.dispatch(resolveCollectionShare(collectionData.channel, collectionData.id, this.props.id, true))
    }

    denyShare = () => {
        let collectionData = this.props.collections.collections.find(
            (collection) => collection.data.collection.id === this.props.id
        )
            
        this.props.dispatch(resolveCollectionShare(collectionData.channel, collectionData.id, this.props.id, false))
    }

    render() {
        const editModalId = uuidv4()
        const newModalId = uuidv4()
        let collectionData = this.props.collections.collections.find(
            (collection) => collection.data.collection.id === this.props.id
        )
        let cloneStyle = {
            backgroundColor: "rgb(29, 68, 116)"
        }
        let collectionStyle = {
            backgroundColor: collectionData.data.color || ""
        }
        let pendingShare = (collectionData.data.cloned_from == null && collectionData.data.pending_approval == true && collectionData.data.write_access == false)

        return (
            <Draggable draggableId={"collection-" + this.props.id} index={this.props.index} isDragDisabled={this.props.index === 0}>
                {provided => (
                    <div {...provided.draggableProps} ref={provided.innerRef} className="column">

                        <div className="inner-wrap" style={collectionStyle}>
                           
                            <button className="col-functions action-modal" onClick={() => this.props.dispatch(openModal({
                                id: editModalId,
                                type: "custom",
                                panel: "collection",
                                content: <EditCollection index={this.props.index} id={collectionData.data.collection.id} channel={this.props.channel} modalId={editModalId} />,
                            }))}>...</button>
                            
                            {collectionData.data.collection.files.length > 0 ? <span className="attach"></span> : ""}
                            {collectionData.data.collection.published ? <span className="flag">public</span> : ""}
                            {collectionData.data.cloned_from == null ? "" : <span className="flag" style={cloneStyle}>Cloned</span>}
                            


                            {(collectionData.data.cloned_from == null && collectionData.data.pending_approval == true && collectionData.data.write_access == false) && <span className="flag" style={cloneStyle}>Pending share</span>}

                            {( collectionData.data.cloned_from == null && collectionData.data.pending_approval == false && collectionData.data.write_access == true && collectionData.data.collection.write_users.length > 1) && <span className="flag" style={cloneStyle}>Shared</span>}

                            <h3 className="group-title" {...provided.dragHandleProps} className="title">                    {collectionData.data.collection.title}
                            </h3>

                            {pendingShare &&
                            <div>
                                This collection has been shared with you. Do you wish to colaborate?
                                <span onClick={this.acceptShare}>Accpect</span>
                                <span onClick={this.denyShare}>Deny</span>
                            </div>
                            }

                            <Droppable droppableId={"droppable-" + collectionData.data.collection.id} type="resource" isDropDisabled={!collectionData.data.write_access}>
                                {provided => (
                                    <div
                                        className={"drag-blocks " + (this.props.className ? this.props.className : "")}
                                        data-collection={collectionData.data.collection.id}
                                        ref={provided.innerRef}>
                                        
                                        {collectionData.data.collection.resources.map((resource, index) => {
                                            return (
                                                <Resource
                                                    key={resource.id}
                                                    id={resource.id}
                                                    canEdit={collectionData.data.write_access}
                                                    index={index}
                                                    type={resource.type}
                                                    hasFiles={(resource.files.length > 0)}
                                                    channel={this.props.channel}
                                                    parent={collectionData.data.collection.id} />
                                            )
                                        }
                                        )}

                                        {provided.placeholder}
                                    </div>
                                )}
                            </Droppable>

                            {collectionData.data.write_access ?
                                <button className="action-modal add-custom" onClick={() => this.props.dispatch(openModal({
                                    id: newModalId,
                                    type: "custom",
                                    panel: "collection",
                                    content: <NewResource parent={collectionData.data.collection.id} channel={this.props.channel} modalId={newModalId} />,
                                }))}>Add Custom Item</button>
                                : null}
                        </div>
                    </div>
                )}
            </Draggable>
        )
    }
}

export default connect(
    function mapStateToProps(state) {
        return {
            modals: state.modals,
            collections: state.collections
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(Collection)