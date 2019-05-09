import React from "react"
import ReactDOM from "react-dom"
import { uuidv4 } from "../../utils"

export default class PermaLinkModalPortal extends React.PureComponent {
    constructor(props) {
        super(props)
      
        this.collections = document.getElementById("perma-link")

        this.el = document.createElement("div")
        // setting an id makes it so we can remove the empty div left when the modal is closed
        this.elementId = uuidv4()
        this.el.setAttribute("id", this.elementId)
    }
  
    componentDidMount() {
        this.collections.appendChild(this.el)
    }
  
    componentWillUnmount() {
        const child = document.getElementById(this.elementId)

        child.parentNode.removeChild(child)
    }

    render() {
        return ReactDOM.createPortal(this.props.children, this.el)
    }
}