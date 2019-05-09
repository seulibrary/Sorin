import React, { Component } from "react"
import { connect } from "react-redux"
import {Draggable} from "react-beautiful-dnd"
import InnerResource from "./InnerResource"

class Resource extends Component {
    constructor(props) {
        super(props)
    }

    render() {
        let collectionData = this.props.collections.collections.find(
            collection => collection.data.collection.id === this.props.parent
        )
        
        let data = collectionData.data.collection.resources[this.props.index]

        return (
            <Draggable
                key={"draggable-"+this.props.id}
                draggableId={"resource-"+this.props.id}
                index={this.props.index}
                isDragDisabled={!this.props.canEdit}
            >
                {(provided) => (
                    <div
                        data-resource={this.props.id}
                        ref={provided.innerRef}
                        {...provided.draggableProps}
                        {...provided.dragHandleProps}
                    >
                        <InnerResource
                            index={this.props.index}
                            title={data.title}
                            id={this.props.id}
                            hasFiles={this.props.hasFiles}
                            type={this.props.type}
                            canEdit={this.props.canEdit}
                            parent={this.props.parent}
                            channel={this.props.channel} />
                    </div>
                )}
            </Draggable>
        )
    }
}

export default connect(
    function mapStateToProps(state) {
        return {
            collections: state.collections,
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(Resource)
