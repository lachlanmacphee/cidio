//
//  FirebaseUnit.swift
//  Cidio
//
//  Created by Lachlan MacPhee on 4/5/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct CidioUnitAssessment: Codable {
    var name: String? // Name of the assessment
    var worth: Double? // Worth or value of the assessment
}

struct CidioUnitClass: Codable {
    var locations: [String]? // Locations where the class is held
    var name: String? // Name of the class
}

struct CidioUnitReview: Codable {
    var from: String? // Name or identifier of the reviewer
    var rating: Float? // Rating given by the reviewer
    var comment: String? // Reviewer's comment or feedback
}

struct CidioUnit: Codable {
    @DocumentID var id: String? // Document ID of the unit in Firestore
    var unitName: String? // Name of the unit
    var year: String? // Year of the unit
    var faculty: String? // Faculty or department of the unit
    var location: String? // Location of the unit
    var assessments: [CidioUnitAssessment]? // Array of assessments associated with the unit
    var classes: [CidioUnitClass]? // Array of classes associated with the unit
    var reviews: [CidioUnitReview]? // Array of reviews associated with the unit
    var staff: [String]? // Array of staff members associated with the unit
}

struct CidioUniversityData: Codable {
    var faculties: [String]? // Array of faculties in the university
    var staff: [String]? // Array of staff members in the university
}

