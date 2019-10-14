import React, { Component } from "react"
import Citation from "../Citation"
import { connect } from "react-redux"
import { openModal } from "../../actions/modal"
import { uuidv4 } from "../../utils"
import Accordion from "../Accordion"
import { createResource, saveResourceToCookie } from "../../actions/collections"
import { Redirect } from 'react-router'
import {withRouter} from 'react-router-dom'
import ErrorBoundary from "../../containers/Errors"
import ViewResource from './resource'
class SearchResult extends Component {
    constructor(props) {
        super(props)

        this.state = {
            saveit: <span>save to collections</span>,
            clicked: ""
        }
    }

    onSave = () => {
        if (this.state.saveit != "saved!") {
            if (!this.props.session.currentUser) {
                this.setState({
                    saveit: "saving...",
                    clicked: " clicked"
                })
                // save item to local storage
                this.props.dispatch(
                    openModal({
                        id: uuidv4,
                        type: "confirmation",
                        buttonText: ["Sign in", "Cancel"],
                        onConfirm: () => {
                            let params = this.props.location.search ? this.props.location.search : "";
                            let login_state = JSON.stringify({url: this.props.location.pathname + params});

                            saveResourceToCookie(this.props.data, login_state)
                        },
                        onCancel: () => {
                            this.resetSaveItState()
                        },
                        onClose: () => {
                            this.resetSaveItState()
                        },
                        text: "Would you like to sign in and save this item?"
                    })
                )
            } else {
                this.setState({
                    saveit: "saved!",
                    clicked: " clicked"
                })
                
                let inbox = this.props.collections.collections.map( collection => {
                    if (collection.data.collection.id === this.props.session.inbox_id) {
                        return collection
                    }
                })
    
                if (inbox.length > 0) {
                    createResource(inbox[0].channel, this.props.session.inbox_id, this.props.data)
                } else {
                    this.setState({
                        saveit: "Not Saved!",
                        clicked: " error"
                    })
                }
            }    
        }
    }

    resetSaveItState = () => {
        this.setState({
            saveit: <span>save to<br/> collections</span>
        })
    }

    checkInbox = (resource) => {
        if (this.props.collections.collections.length > 0) {
            let resources = this.props.collections.collections[0].data.collection.resources // inbox resources
            if (resources.length > 0) {
                resources.map( res => {
                    if (res.identifier === resource.identifier) {
                        this.setState({
                            saveit: "saved!"
                        })
                    }
                })
            }
        }
    }

    componentDidMount() {
        this.checkInbox(this.props.data)
    }

    openResource = () => {
        this.props.dispatch(openModal(
            {
                id: uuidv4,
                type: "custom",
                panel: this.props.panel || "search",
                content: 
                    <ViewResource index={this.props.index} data={this.props.data}  />,

                })
            )
    }

    render() {
        const data = this.props.data
        
        return (
            <div className="result show">
                <ErrorBoundary>
                <span className="count">{this.props.index + 1}</span>
                <div className={"icon " + data.type}></div>
                <div className="info">
                    <h5><span>{data.type}</span></h5>
                    <h4>
                        <a target="_blank" onClick={this.openResource}>{data.title}</a>
                        { data.date ? <i>({data.date})</i> : "" }
                    </h4>
                    <div className="contrib">
                      
                        <span><i>{data.creator ? data.creator.join("; "): ""}</i></span>
                        
                        <span>
                        {data.contributor ? data.contributor.join("; "): ""}
                        </span>

                        <span>{data.is_part_of}</span>
                        
                        { data.call_number && data.availability_status == "available" && <span className="callNumber available">{data.call_number} - Available for checkout</span> }
                        
                        { data.call_number && data.availability_status == "unavailable" && <span className="callNumber unavailable">{data.call_number} - Currently unavailable</span> }
                    </div>
                </div>

                <div className="actions">
                    <a className={"save" + this.state.clicked} data-context="L" onClick={this.onSave}>
                        <span className="flag">{this.state.saveit}</span>
                    </a>
                </div>
                </ErrorBoundary>
            </div>
        )
    }
}

export default withRouter(connect(
    function mapStateToProps(state) {
        return {
            modals: state.modals,
            session: state.session,
            collections: state.collections
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(SearchResult))
