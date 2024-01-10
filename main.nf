#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//---------------------------------------------------------------
// Including Workflows
//---------------------------------------------------------------

include { allBlastWorkflow } from './modules/peripheral.nf'
include { bestRepBlastWorkflow } from './modules/peripheral.nf'
include { listToPairwiseComparisons; coreOrResidualWorkflow as coreWorkflow } from './modules/core.nf'

//---------------------------------------------------------------
// allBlast
//---------------------------------------------------------------

workflow allBlastEntry {
  if(params.peripheralProteomes) {
    inputFile = Channel.fromPath(params.peripheralProteomes)
  }
  else {
    throw new Exception("Missing params.peripheralProteome")
  }

  allBlastWorkflow(inputFile)
   
}

//---------------------------------------------------------------
// bestRepBlast
//---------------------------------------------------------------

 workflow bestRepBlastEntry {
   if(params.peripheralProteomes) {
     inputFile = Channel.fromPath(params.peripheralProteomes)
   }
   else {
     throw new Exception("Missing params.peripheralProteome")
   }

   bestRepBlastWorkflow(inputFile)
   
 }
