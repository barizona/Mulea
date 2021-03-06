
KolmogorovSmirnovTest <- setClass("KolmogorovSmirnovTest",
                                  slots = list(
                                    gmt = "data.frame",
                                    testData = "character",
                                    numberOfPermutations = "numeric",
                                    test = "function"
                                  ))

setMethod("initialize", "KolmogorovSmirnovTest",
          function(.Object,
                   gmt = data.frame(),
                   testData = character(),
                   numberOfPermutations = 1000,
                   test = NULL,
                   ...) {

            .Object@gmt <- gmt
            .Object@testData <- testData
            .Object@numberOfPermutations <- numberOfPermutations

            .Object@test <- function(testObject) {
              pvalues <- sapply(testObject@gmt$listOfValues,
                                function(categoryValues) {
                                  matchedFromModel <- match(categoryValues, testObject@testData)
                                  matchedFromModelDist <- matchedFromModel[!is.na(matchedFromModel)]
                                  if (length(matchedFromModelDist) == 0) {
                                    return(NA)
                                  }
                                  pvaluesFromPermutationTest <- aaply(.data = 1:testObject@numberOfPermutations, .margins = 1, .fun = function(element) {
                                    randomFromExperimentDist <- sort(sample(seq_len(length(testObject@testData)), length(matchedFromModelDist)))
                                    ks.test(matchedFromModelDist, randomFromExperimentDist)$p.value
                                  })
                                  mean(pvaluesFromPermutationTest)
                                })
              resultDf <- data.frame(testObject@gmt, "p.value" = pvalues)
              resultDf
            }

            .Object

          })

setMethod("runTest",
          signature(testObject = "KolmogorovSmirnovTest"),
          function(testObject) {
            testObject@test(testObject)
          })
