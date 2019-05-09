import React, { Component } from "react"
import ReactDOM from "react-dom"
import { withRouter } from "react-router-dom"
import { connect } from "react-redux"
import { DragDropContext, Droppable } from "react-beautiful-dnd"
import ScrollIntoView from "scroll-into-view"
import { openModal } from "../../actions/modal"
import { moveCollection, moveResource } from "../../actions/collections"
import { uuidv4 } from "../../utils"
import { Collection, NewCollectionForm } from "../../components/Collection"

class Collections extends Component {
    constructor(props) {
        super(props)
        this.createCollectionRef = React.createRef()
    }
    
    updateWindowDimensions = () => {
        document.getElementById("collections").style.height = ( window.innerHeight - (  document.getElementById("header").offsetHeight + document.getElementById("tabs").offsetHeight  )) + "px" 	  
    }
	
    componentDidMount() {
        this.updateWindowDimensions()
        window.addEventListener("resize", this.updateWindowDimensions)
    }
    
    componentWillUnmount() {
        window.removeEventListener("resize", this.updateWindowDimensions)
    }
    
    onDragEnd = (result) => {
        const { destination, source, draggableId, type } = result

        if (!destination) {
            return
        }
        
        if (destination.droppableId === source.droppableId &&
            destination.index === source.index
        ) {
            return
        }
        
        if (type === "column") {
            if (destination.index != 0) {
                this.props.dispatch(moveCollection(
                    this.props.session.dashboardChannel,
                    draggableId.split("-")[1],
                    destination.index,
                    source.index
                ))
            } else {
                return null
            }
        } else if (type === "resource") {
            this.props.dispatch(moveResource(
                this.props.session.dashboardChannel, 
                draggableId.split("-")[1], 
                source.droppableId.split("-")[1], 
                destination.droppableId.split("-")[1], 
                destination.index))
        }

        return
    }

    handleScrollToElement = () => {
        ScrollIntoView(ReactDOM.findDOMNode(this.createCollectionRef.current), {align: {top: 1}})
    }

    render() {
        let modalId = uuidv4()

        return (
            <div id="collections">
                <DragDropContext onDragEnd={this.onDragEnd}>
                    <Droppable droppableId="all-collections" direction="horizontal" type="column">
                        {provided => (
                            <div
                                {...provided.droppableProps}
                                ref={ provided.innerRef }
                            >
                                { this.props.collections ? 
                                    this.props.collections.collections.map((collection, index) => {
                                        return (
                                            <Collection
                                                key={"key-"+collection.data.collection.id}
                                                index={index}
                                                id={collection.data.collection.id}
                                                channel={collection.channel}
                                            />
                                        )
                                    })
                                    : null }
                                { provided.placeholder }
                            </div>
                        )}
                    </Droppable>
                </DragDropContext>

                <div className="column" id="make-new-collection" ref={this.createCollectionRef}>
                    <div className="make-new-collection action-modal" onClick={() => this.props.dispatch(
                        openModal({
                            id: modalId,
                            type: "custom",
                            panel: "collection",
                            content: <NewCollectionForm user={this.props.session} id={modalId} onClose={this.handleScrollToElement} /> ,
                        }))}><span className="button-title">Create Collection</span>
                    </div> 
                </div>
            </div>
        )
    }
}

export default withRouter(connect(
    function mapStateToProps(state) {
        return {
            collections: state.collections,
            modals: state.modals,
            session: state.session
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(Collections))