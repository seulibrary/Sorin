import React, { Component, useEffect } from 'react';

import {exampleSetup, buildMenuItems} from "prosemirror-example-setup"
import {Step} from "prosemirror-transform"
import {EditorState} from "prosemirror-state"
import {EditorView} from "prosemirror-view"
import {history} from "prosemirror-history"
import {collab, receiveTransaction, sendableSteps, getVersion} from "prosemirror-collab"

import {schema} from "./schema"

import { 
  EditorState as DJSEditorState,
  ContentState, 
  convertFromRaw 
} from "draft-js"
import { stateToHTML } from "draft-js-export-html"
import {DOMParser} from "prosemirror-model"
import './style.css';

import IntervalSave from "./intervalSave"

export default class CollabEditor extends Component {
  constructor(props) {
    super(props)
  }

  componentDidMount() {

    // TODO: Make sure Version is being loaded and saved
    // TODO: CHeck for other users on connect. Sync state.

    this.auth = new Authority(this.convertNote(this.props.data))
    
    this.collabEditor(this.auth)
  }

  componentWillUnmount() {
    this.saveNote()
  }

  saveNote = () => {
    this.props.onChange(this.props.id, JSON.stringify(this.auth))
  }

  collabEditor = (authority) => {
    let menu = buildMenuItems(schema).fullMenu
    let channel = this.props.collectionChannel
    
    console.log("auth", authority)

    let view = new EditorView(this.editor, {
      state: EditorState.create({
        doc: authority.doc,
        plugins: exampleSetup({schema, history: false, menuContent: menu}).concat([
          history({preserveItems: true}),
          collab({version: authority.version})
        ])
      }),
      dispatchTransaction(transaction) {
        let newState = view.state.apply(transaction)
        view.updateState(newState)
        let sendable = sendableSteps(newState)
        if (sendable) {
          let steps = sendable.steps.map(s => s.toJSON())
          
          let data = {version: sendable.version, clientId: sendable.clientID, steps: steps}

          channel.push("update_note", {payload: data})

          authority.receiveSteps(sendable.version, steps.map(s => Step.fromJSON(schema, s)),
            sendable.clientID)
        }
      },
      handlePaste: (view, event, slice) => {console.log(event)}
    })
    
    authority.onNewSteps.push(function() {
      let newData = authority.stepsSince(getVersion(view.state))
      view.dispatch(
        receiveTransaction(view.state, newData.steps, newData.clientIDs))
    })

    this.props.collectionChannel.on("update_note", payload => {
      let data = payload.payload
      authority.receiveSteps(data.version, data.steps.map(s => Step.fromJSON(schema, s)), data.clientID)
    })

    return view
  }
  
  convertNote = (note) => {
    let data = {}
    if (this.isJson(note)) {
      data = JSON.parse(note)
      if (data.hasOwnProperty("blocks")) {
        // content is draft-js
        if (this.isJson(note)) {
          data = DJSEditorState.createWithContent(convertFromRaw(JSON.parse(note)))
        } else if (note) {
          data = DJSEditorState.createWithContent(ContentState.createFromText(note))
        } else {
          data = DJSEditorState.createEmpty()
        }

        let domNode = document.createElement("div")
        domNode.innerHTML = stateToHTML(data.getCurrentContent())
        let exports = DOMParser.fromSchema(schema).parse(domNode)
        
        this.saveNote()

        return exports

      } else {
        return  schema.nodeFromJSON(data.doc)
      }
    } else {
      return note
    }
  }

  isJson = (str) => {
      try {
          JSON.parse(str)
      } catch (e) {
          return false
      }
      return true
  }

  render() {
    return (
      
      <div className="DraftEditor-root" ref={ r => this.editor = r}>
        <IntervalSave save={this.saveNote} />
        <div ref= {r => this.content = r}/>
      </div>
    );
  }
}

class Authority {
  constructor(doc) {
    this.doc = doc
    this.steps = []
    this.stepClientIDs = []
    this.onNewSteps = []
  }
  
  receiveSteps(version, steps, clientID) {
    if (version != this.steps.length) return

    // Apply and accumulate new steps
    steps.forEach(step => {
      this.doc = step.apply(this.doc).doc
      this.steps.push(step)
      this.stepClientIDs.push(clientID)
    })

    // Signal listeners
    this.onNewSteps.forEach(function(f) { f() })
  }

  stepsSince(version) {
    return {
      steps: this.steps.slice(version),
      clientIDs: this.stepClientIDs.slice(version)
    }
  }
}

