#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { calculateGroupResults; uncompressFastas; uncompressFastas as uncompressPeripheralFastas; collectDiamondSimilaritesPerGroup} from './shared.nf'

process createCompressedFastaDir {
  container = 'rdemko2332/orthofindernextflow'

  input:
    path inputFasta

  output:
    path 'fastas.tar.gz', emit: fastaDir
    stdout emit: complete

  script:
    template 'createCompressedFastaDir.bash'
}

process createDatabase {
  container = 'rdemko2332/orthofindernextflow'

  input:
    path newdbfasta

  output:
    path 'newdb.dmnd'

  script:
    template 'createDatabase.bash'
}

process peripheralDiamond {
  container = 'veupathdb/diamondsimilarity'

  input:
    path fasta
    path database
    val outputList

  output:
    path '*.out', emit: similarities
    path fasta, emit: fasta

  script:
    template 'peripheralDiamondSimilarity.bash'
}

process assignGroups {
  container = 'rdemko2332/orthofindernextflow'

  input:
    path diamondInput
    path fasta
    path groupsFile
    val allBlast
        
  output:
    path 'groups.txt', emit: groups
    path diamondInput, emit: similarities
    path fasta, emit: fasta

  script:
    template 'assignGroups.bash'
}

process makeResidualAndPeripheralFastas {
  container = 'rdemko2332/orthofindernextflow'

  publishDir params.outputDir, mode: "copy"
  
  input:
    path groups
    path seqFile
        
  output:
    path 'residuals.fasta', emit: residualFasta
    path 'peripherals.fasta', emit: peripheralFasta

  script:
    template 'makeResidualAndPeripheralFastas.bash'
}

workflow allBlastWorkflow { 
  take:
    peripheralDir

  main:

    // Uncompress input directory that contains a proteome fasta per organism. This is done for both the core and peripheral.
    uncompressAndMakePeripheralFastaResults = uncompressPeripheralFastas(peripheralDir)

    // Create a diamond database from a fasta file of the core proteome
    database = createDatabase(params.coreProteomes)

    // Run Diamond (forks so we get one process per organism; )
    similarities = peripheralDiamond(uncompressAndMakePeripheralFastaResults.proteomes.flatten(), database, params.orthoFinderDiamondOutputFields)

    // Assigning Groups
    groupsAndSimilarities = assignGroups(similarities.similarities, similarities.fasta, params.groupsFile, true)

    // split out residual and peripheral per organism and then collect into residuals and peripherals fasta
    residualAndPeripheralFastas = makeResidualAndPeripheralFastas(groupsAndSimilarities.groups, groupsAndSimilarities.fasta)

    residualFasta = residualAndPeripheralFastas.residualFasta.collectFile(name: 'residual.fasta');
    peripheralFasta = residualAndPeripheralFastas.peripheralFasta.collectFile(name: 'peripheral.fasta');

    // collect up the groups
    groupAssignments = groupsAndSimilarities.groups.collectFile(name: 'groups.txt', storeDir: params.outputDir)

}


 workflow bestRepBlastWorkflow { 
   take:
     peripheralDir

   main:

     // Uncompress input directory that contains a proteome fasta per organism. This is done for both the core and peripheral.
     uncompressAndMakePeripheralFastaResults = uncompressPeripheralFastas(peripheralDir)

     // Create a diamond database from a fasta file of the core proteome
     database = createDatabase(params.coreBestReps)

     // Run Diamond (forks so we get one process per organism; )
     similarities = peripheralDiamond(uncompressAndMakePeripheralFastaResults.proteomes.flatten(), database, params.orthoFinderDiamondOutputFields)

     // Assigning Groups
     groupsAndSimilarities = assignGroups(similarities.similarities, similarities.fasta, params.groupsFile, false)

     // split out residual and peripheral per organism and then collect into residuals and peripherals fasta
     residualAndPeripheralFastas = makeResidualAndPeripheralFastas(groupsAndSimilarities.groups, groupsAndSimilarities.fasta)

     residualFasta = residualAndPeripheralFastas.residualFasta.collectFile(name: 'residual.fasta');
     peripheralFasta = residualAndPeripheralFastas.peripheralFasta.collectFile(name: 'peripheral.fasta');

     // collect up the groups
     groupAssignments = groupsAndSimilarities.groups.collectFile(name: 'groups.txt', storeDir: params.outputDir)

 }
