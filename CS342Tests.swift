//
//  CS342Tests.swift
//  CS342Tests
//
//  Created by Samali namaganda on 1/12/25.
//

import Testing
import XCTest

@testable import CS342

struct CS342Tests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

/* asked gemini to help me write the tests to my code
 prompt given my code [copy and paste], help me write appropriate tests to check for the following methods: 1. test prescribed medication, determine transfusion
 made edits regarding incorrect function class and missing parameters for "medication", other than that no major edits because i'm still not proficient in writing good tests
 */
class PatientTests: XCTestCase {

    var patient: Patient!
    let birthdate = Calendar.current.date(from: DateComponents(year: 1990, month: 5, day: 15))! // Fixed date for tests

    override func setUpWithError() throws {
        patient = Patient(mrn: 12345, firstName: "John", lastName: "Doe", dateOfBirth: birthdate, height: 180, weight: 75, bloodType: .Aplus, allMedications: <#Set<medication>#>)
    }

    override func tearDownWithError() throws {
        patient = nil
    }

    func testPatientProperties() {
        XCTAssertEqual(patient.mrn, 12345)
        XCTAssertEqual(patient.firstName, "John")
        XCTAssertEqual(patient.lastName, "Doe")
        XCTAssertEqual(patient.dateOfBirth, birthdate)
        XCTAssertEqual(patient.height, 180)
        XCTAssertEqual(patient.weight, 75)
        XCTAssertEqual(patient.bloodType, .Aplus)
        XCTAssertEqual(patient.allMedications.count, 0) // Initially empty
        XCTAssertEqual(patient.age, Calendar.current.component(.year, from: Date()) - 1990)
    }

    func testAgeAndName() {
        XCTAssertEqual(patient.AgeAndName(), "Doe, John (\(Calendar.current.component(.year, from: Date()) - 1990) years)")
    }

    func testPrescribeMedication_success() throws {
        let medication = medication(datePrescribed: Date(), name: "Aspirin", dose: 81, doseUnits: "mg", route: "Oral", frequency: 1, duration: 30)
        try patient.prescribeMedication(medication)
        XCTAssertEqual(patient.allMedications.count, 1)
        XCTAssertTrue(patient.allMedications.contains(medication))
    }

    func testPrescribeMedication_duplicate() throws {
        var medication1 = medication(datePrescribed: Date(), name: "Aspirin", dose: 81, doseUnits: "mg", route: "Oral", frequency: 1, duration: 30)
        try patient.prescribeMedication(medication1)
        let medication2 = medication(datePrescribed: Date(), name: "Aspirin", dose: 81, doseUnits: "mg", route: "Oral", frequency: 1, duration: 30)
        XCTAssertThrowsError(try patient.prescribeMedication(medication2)) { error in
            XCTAssertEqual(error as? MedicationError, .alreadyPrescribed)
/*
 gemini previously provided
 func testPrescribeMedication_duplicate() throws {
         var medication = Medication(datePrescribed: Date(), name: "Aspirin", dose: 81, doseUnits: "mg", route: "Oral", frequency: 1, duration: 30)
         try patient.prescribeMedication(medication)
         medication = Medication(datePrescribed: Date(), name: "Aspirin", dose: 81, doseUnits: "mg", route: "Oral", frequency: 1, duration: 30)
         XCTAssertThrowsError(try patient.prescribeMedication(medication)) { error in
             XCTAssertEqual(error as? MedicationError, .alreadyPrescribed)
 this threw up an error "cannot call value of a non-function type "medication". The code was rewritten to rectify the error
 */
        }
    }

    func testCurrentMedications() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        let futureDate = Calendar.current.date(byAdding: .day, value: 50, to: Date())!
        let medication1 = medication(datePrescribed: pastDate, name: "OldMed", dose: 10, doseUnits: "mg", route: "IV", frequency: 1, duration: 50)
        let medication2 = medication(datePrescribed: futureDate, name: "CurrentMed", dose: 20, doseUnits: "mg", route: "Oral", frequency: 2, duration: 100)
        do{
            try patient.prescribeMedication(medication1)
            try patient.prescribeMedication(medication2)
        } catch{
            print("error")
        }
        
        let currentMeds = patient.currentMedications()
        XCTAssertEqual(currentMeds.count, 1)
        XCTAssertEqual(currentMeds[0].0, "CurrentMed")
    }

    func testDetermineTransfusion() {
        XCTAssertEqual(patient.determineTransfusion(), "Patient can only be transfused with [A+, A-, O+, O-]")

        let oMinusPatient = Patient(mrn: 67890, firstName: "Jane", lastName: "Smith", dateOfBirth: birthdate, height: 160, weight: 60, bloodType: .Ominus, allMedications: <#Set<medication>#>)
        XCTAssertEqual(oMinusPatient.determineTransfusion(), "Patient can only be transfused with [O-]")

        let abPlusPatient = Patient(mrn: 13579, firstName: "Bob", lastName: "Johnson", dateOfBirth: birthdate, height: 175, weight: 80, bloodType: .ABplus, allMedications: <#Set<medication>#>)
        XCTAssertEqual(abPlusPatient.determineTransfusion(), "Patient can be transfused with any blood type")

        let unknownPatient = Patient(mrn: 24680, firstName: "Chris", lastName: "Davis", dateOfBirth: birthdate, height: 170, weight: 70, bloodType: nil, allMedications: <#Set<medication>#>)
        XCTAssertEqual(unknownPatient.determineTransfusion(), "Patient cannot be transfused because their blood type is unknown")
    }
}
