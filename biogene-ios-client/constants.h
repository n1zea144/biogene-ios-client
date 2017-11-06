/*
 *  constants.h
 *  biogene-client
 *
 *  Created by Benjamin on 6/11/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

// activity indicator view - if you adjust these, you need to adjust XXXActivityX, XXXActivityY below
#define kActivityViewWidth 30
#define kActivityViewHeight 30

// general html header
#define kHTMLHeader @"<html><head><meta name=\"viewport\" content=\"width=320\"/></head><body>"
#define kHTMLHeaderClose @"</body></html>"

// custom styles
#define kBaseFontSize 18
#define kMaxBaseFontSize 30
#define kMinBaseFontSize 6
#define kFontSizePlaceHolder @"FONT-SIZE"
#define kSummaryBaseStyle @"<style type=\"text/css\"><!-- body { font-family:Arial; font-size:18px; color:#000000; }--></style>"
#define kFunctionBaseStyle @"<style type=\"text/css\"><!-- body { font-family:Arial; font-size:FONT-SIZE; color:#000000; }--></style>"
#define kRIFBaseStyle @"<style type=\"text/css\"><!-- body { font-family:Arial; font-size:FONT-SIZE; color:#000000; }--></style>"
#define kNoResultsBaseStyle @"<style type=\"text/css\"><!-- body { font-family:Arial; font-size:18px; color:#000000; }--></style>"
#define kMiscMesgBaseStyle @"<style type=\"text/css\"><!-- body { font-family:Arial; font-size:18px; color:#000000; }--></style>"

#define kMaxHeaderFontSize 30
#define kMinHeaderFontSize 6
#define kMaxValueFontSize 30
#define kMinValueFontSize 6
#define kBaseHeaderFontSize 18
#define kBaseValueFontSize 18
#define kCustomH1Style @"<style type=\"text/css\"><!-- h1 { font-family:Arial; font-size:FONT-SIZE; font-weight:bold; color:#000000; margin-bottom:2px; margin-top:12px;}--></style>"
#define kCustomH2Style @"<style type=\"text/css\"><!-- h2 { font-family:Arial; font-size:FONT-SIZE; font-weight:normal; color:#000000; margin-bottom:12px; margin-top:2px;}--></style>"
#define kCustomH2SummaryStyle @"<style type=\"text/css\"><!-- h2 { font-family:Arial; font-size:FONT-SIZE; font-weight:normal; color:#000000; margin-bottom:2px; margin-top:2px;}--></style>"

// reachability
#define kReachabilityAlertTitle @"No Network Connection"
#define kReachabilityAlertMessage @"There appears to be a problem with the Internet connection.  Please try again later or check your Internet settings."

// proxy server url
#define kAliasesDesignationsDelimiter @", "
#define kDelimiter @":"
#define kSpace @" "
#define kURLSpace @"%20"
#define kQueryPlaceHolder @"QUERY"
#define kOrganismPlaceHolder @"ORGANISM"
#define kRetStartPlaceHolder @"RETSTART"
#define kRetStartDefaultValue @"0"
#define kRetMaxPlaceHolder @"RETMAX"
#define kBioGENEProxyServer @""
#define kBioGENEProxyURL @""

// codes returned by biogene proxy server
#define kSuccessCode @"SUCCESS"
#define kFailureCode @"FAILURE"
#define kIDNotFoundCode @"ID_NOT_FOUND"

// prefs - these should equals values in Root.plist
#define k25RIFsPerPage @"25 References Per Page"
#define k50RIFsPerPage @"50 References Per Page"
#define k75RIFsPerPage @"75 References Per Page"
#define k100RIFsPerPage @"100 References Per Page"
#define k200RIFsPerPage @"200 References Per Page"
#define k5RecordsPerPage @"5 Genes Per Page"
#define k10RecordsPerPage @"10 Genes Per Page"
#define k25RecordsPerPage @"25 Genes Per Page"
#define k50RecordsPerPage @"50 Genes Per Page"
#define k100RecordsPerPage @"100 Genes Per Page"
// default values for prefs
#define kDefaultOrganism @"Human"
#define kDefaultRIFsPerPage @"100 References Per Page"
#define kDefaultRetMax @"25 Genes Per Page"

// pagination str
#define kPaginationStartPlaceHolder @"START"
#define kPaginationEndPlaceHolder @"END"
#define kPaginationTotalPlaceHolder @"TOTAL"
#define kGeneResultsPaginationLabel @"Genes START - END of TOTAL"
#define kRIFResultsPaginationLabel @"References START - END of TOTAL"

// InfoViewController
#define kInfoViewControllerTitle @"Information"
#define kInfoViewActivityViewX 145
#define kInfoViewActivityViewY 236
#define kURLToReadme @""

// PrefsViewController
#define kPrefsViewControllerTitle @"Settings"
#define kRowHeight 50.0
#define kRowLabelHeight 22.0
#define kOrganismFilterKey @"organism" // see Root.plist
#define kRIFsPerPageKey @"referencesPerPage"    // see Root.plist
#define kEnableAutorotationKey @"enableRotation" // see Root.plist
#define kAutorotationTrueValue @"enabled" // see Root.plist
#define kAutorotationFalseValue @"disabled" // see Root.plist
#define kRetMaxKey @"retmax" // see Root.plist
#define kFiltersSectionTitle @"Filters" // see Root.plist
#define kViewingSectionTitle @"Viewing" // see Root.plist
#define kOrganismFilterTitle @"Organism" // see Root.plist
#define kShowRIFsPerPageTitle @"Show" // see Root.plist
#define kEnableAutorotationTitle @"Autorotation" // see Root.plist
#define kRetMaxTitle @"Show" // see Root.plist
#define ORGANISM_FILTER_INDEX 1 // following define should change if location of organism filter in settings bundle changes
#define RET_MAX_INDEX 3         // following define should change if location of recordsPerPage filter in settings bundle changes
#define RIFS_PER_PAGE_INDEX 4   // following define should change if location of rifsPerPage filter in settings bundle changes

// PrefsViewCell
#define kCellHeight	24.0
#define kCellLeftOffset	8.0
#define kCellTopOffset 12.0
#define kAutorotationSwitchWidth 94.0
#define kAutorotationSwitchHeight 27.0

// SearchViewController string constants
#define kSearchViewActivityViewX 145
#define kSearchViewActivityViewY 205
#define kUnexpectedErrorTitle @"Communications Error"
#define kUnexpectedError @"There was a problem communicating with the BioGene data server.  Please try again."

// SwitchViewController
#define kSwitchViewControllerTitle @"Summary"

// SearchResultsViewController
#define kSearchResultsActivityViewX 173
#define kSearchResultsActivityViewY 246
#define kSearchResultsViewControllerTitle @"Genes"

// NoResultsViewController string constants
#define kNoResultsViewControllerTitle @"Search Results"
#define kNoRecordsFound @"No records were found."
#define kErrorFetchingParsingData @"Error while fetching or parsing data.  Please try again."
#define kInternalError @"Internal errror."
#define kSearchTermHeading @"Search Term:"
#define kOrganismHeading @"Organism:"  // also used in SummaryViewController
#define kNoResultsFeedback @"Please try entering a different search term or changing your organism filter by clicking on the \"Gear\" on the lower right portion of the search screen."

// SearchResultsCell string constants
#define kNoSymbol @"No Symbol Available." // used in SummaryViewController too
#define kNoDescription @"No Description Available."

// SummaryViewController string constants
#define kOfficialSymbolHeading @"Official Symbol: "
// no symbol available define in SearchResultsCell
#define kName @"Name: "
#define kNoName @"No Name Available."
#define kLocusTag @"Locus Tag: "
#define kAliasesHeading @"Aliases: "
#define kNoAliases @"No Aliases Available."
// organism heading define under NoResultsViewController
#define kSummaryOrganismHeading @"Organism: "
#define kNoOrganism @"No Organism Available."
#define kDesignationsHeading @"Other Designations: "
#define kNoDesignation @"No Designations Available."
#define kHypotheticalProtein @"hypothetical protein"
#define kChromosomeHeading @"Chromosome: "
#define kNoChromosome @"No Chromosome Information Available."
#define kLocationHeading @"Location: "
#define kNoLocation @"No Location Information Available."
#define kMIMHeading @"MIM: "
#define kNoMIM @"No MIM Available."
#define kGeneIDHeading @"GeneID: "
#define kNoGeneID @"No GeneID Available."
#define kHomesapiens @"Homo sapiens"

// FunctionViewControllor string constants
#define kNoFunctionDescription @"No Function Description Available."

// RIFViewController string constants
#define kNoRIFInfo @"No Reference Information Available."
#define kNoRIFs @"No References Available."

// PubMedViewController string constants
#define kPubMedActivityViewX 145
#define kPubMedActivityViewY 215
#define kPubMedViewControllerTitle @"Abstract"
#define kNoPubMedAbstract @"No PubMed Abstract Available."
#define kPubMedReportAndFormat @"?report=Abstract&format=text"

// MiscMessageViewController
#define kMiscMessageViewControllerTitle @"Search Results"
