import React, {Component} from "react"
import { connect } from "react-redux"
import EditResource from "./EditResource"
import { uuidv4 } from "../../utils"
import {openModal} from "../../actions/modal"

class InnerResource extends Component {
    constructor(props) {
        super(props)
    }

    render() {
        const editModalId = uuidv4()

        return (
            <a className="" onClick={() => this.props.dispatch(openModal({
                id: editModalId,
                type: "custom",
                panel: this.props.panel || "collection",
                content: 
                    <EditResource index={this.props.index} id={this.props.id} canEdit={this.props.canEdit} channel={this.props.channel} parent={this.props.parent} modalId={editModalId} {...this.props} />,
            }))}>
			    
                {this.props.hasFiles ? <span className="attach"></span> : "" }
                <i className={"icon " + this.props.type}></i>
                <h4 className="resource-name">{this.props.title}</h4>
            </a>
        )
    }
}

export default connect(
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
)(InnerResource)