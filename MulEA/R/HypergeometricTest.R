
MuleaHypergeometricTest <- setClass("MuleaHypergeometricTest",
                             slots = list(
                               gmt = "data.frame",
                               testData = "character",
                               pool = "character",
                               test = "function"
                             ))

setMethod("initialize", "MuleaHypergeometricTest",
          function(.Object,
                   gmt = data.frame(),
                   testData = character(),
                   pool = character(),
                   test = NULL,
                   ...) {

            .Object@gmt <- gmt
            .Object@testData <- testData
            .Object@pool <- pool

            .Object@test <- function(testObject) {
                testObject@testData <- checkIfPoolIncludeSample(testObject@gmt, testObject@testData, testObject@pool)

                if (0 != length(testObject@pool)) {
                  allElements <- unique(testObject@pool)
                  testObject@gmt <- cutGmtToPool(gmt = testObject@gmt, pool = testObject@pool)
                } else {
                  allElements <- unique(unlist(testObject@gmt$listOfValues))
                }

                testResults <- ddply(.data = testObject@gmt,  .variables = c("ontologyId"), .fun = function(dfRow) {
                  poolAndSelectedAndDBiIntersection <- intersect(testObject@testData, dfRow[1, 'listOfValues'][[1]])

                  selectedAndInGroup <- length(poolAndSelectedAndDBiIntersection)
                  selectedAndOutOfGroup <- length(setdiff(testObject@testData, poolAndSelectedAndDBiIntersection))
                  outOfSelectionAndInGroup <- length(setdiff(dfRow[1, 'listOfValues'][[1]], testObject@testData))
                  outOfSelectionAndOutOfGroup <- length(setdiff(allElements, union(testObject@testData, dfRow[1, 'listOfValues'][[1]])))

                  contingencyTable <- matrix(c(selectedAndInGroup,
                                               selectedAndOutOfGroup,
                                               outOfSelectionAndInGroup,
                                               outOfSelectionAndOutOfGroup),
                                             2, 2)

                  data <- data.frame(
                    'ontologyName' = dfRow['ontologyName'],
                    'listOfValues' = dfRow["listOfValues"],
                    'overlappingData' = I(list(poolAndSelectedAndDBiIntersection)),
                    'contingencyTable' = I(list(contingencyTable)),
                    'p.value' = phyper(selectedAndInGroup - 1,
                                       selectedAndInGroup + outOfSelectionAndInGroup,
                                       selectedAndOutOfGroup + outOfSelectionAndOutOfGroup,
                                       selectedAndInGroup + selectedAndOutOfGroup, lower.tail = FALSE))
                })
                testResults
            }

            .Object

          })

setMethod("runTest",
          signature(testObject = "MuleaHypergeometricTest"),
          function(testObject) {
            testObject@test(testObject)
          })
