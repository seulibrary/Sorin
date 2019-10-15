        
import React, { useState, useEffect } from 'react'

const IntervalSave = (props) => {
  useEffect(() => {
    const interval = setInterval(() => {
        props.save()
    }, 5000) // 5 seconds
    return () => clearInterval(interval)
  }, [])

  return null
}

export default IntervalSave