//
//  ContentView.swift
//  CS342
//
//  Created by Samali namaganda on 1/12/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, CS342!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
/*
n
 */
struct medication: Hashable { // made it hashable so i can use it in sets and dicts >> did this after I kept getting an error about medication needing to be hashable
    var datePrescribed: Date
    let name: String
    var dose: Double // made it variable as the route, dose, duration and frequency might change during the course of treatment
    var doseUnits: String
    var route: String
    var frequency: Int
    var duration: Int // duration in days
}

/*


 */

func main() {
    let metroprolol = medication(datePrescribed: Date(), name: "Metroprolol", dose: 25, doseUnits: "mg", route: "by mouth", frequency: 1, duration: 90)
    print (metroprolol)
}




/*
 Create a type called BloodType, which can be A+, A-, B+, B-, O+, O-, AB+ or AB-.
>> using an enum for this to restrict the entries to A+, A-, B+, B-, O+, O-, AB+ and AB-
 */

// wrote the cases in this format since Swift won't accept just A+ etc because they have special characters
enum BloodType: String {
    case Aplus = "A+"
    case Aminus = "A-"
    case Bplus = "B+"
    case Bminus = "B-"
    case Oplus = "O+"
    case Ominus = "O-"
    case ABplus = "AB+"
    case ABminus = "AB"
}

/*

 included this enum case to be able to throw the error easily
 */
enum MedicationError: Error {
    case alreadyPrescribed
}
class Patient {
    let mrn: Int
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    var height: Double // in case the patient is still growing
    var weight: Double // this is a fluctuating value
    let bloodType: BloodType? // '?' to make it optional
    var allMedications: Set<medication> = [] // made it into a set so that it can catch duplicates
    var age: Int { // all of the code to calculate the age was from Xcode's predictive AI, did not change anything
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
    // the initalizer
    init(mrn: Int, firstName: String, lastName: String, dateOfBirth: Date, height: Double, weight: Double, bloodType: BloodType? = nil, allMedications: Set<medication>) {
        self.mrn = mrn
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.height = height
        self.weight = weight
        self.bloodType = bloodType
        self.allMedications = allMedications
    }
    // first method: returns patient name and age
    func AgeAndName() -> String {
        return "\(firstName) \(lastName), \(age) years"
    }
    // second method: returns current medication being taken
    func currentMedications() -> [(String, Date)] {
        var currentMedicationDict: [String: Date] = [:] // creates an empty dict
        // loop over every medication object
        for medication in allMedications {
            // determine the end date of the medication; used the Xcode autocomplete AI and Apple documentatiion to get this
            if let endDate = Calendar.current.date(byAdding: .day, value: medication.duration, to: medication.datePrescribed),
               endDate > Date() {
                currentMedicationDict[medication.name] = medication.datePrescribed
            }
        }
        // sort the dictionary by the date prescribed; decided to use a dictionary format since it would give key/value pairs for the medications and prescription date which would allow me to sort by the prescription date
        let sortedMedications = currentMedicationDict.sorted { $0.value < $1.value }
        // print the dictionary for debugging
        print("current Medications (unsorted): \(currentMedicationDict)")
        print("current Medications (sorted): \(sortedMedications)")
        return sortedMedications
    }
    // third method:  prescribe new medication to patient
    
    func prescribeMedication(_ medication: medication) throws {
        if allMedications.contains(medication) {
            throw MedicationError.alreadyPrescribed
        }
        
    }
    
    // fourth method: determine what blood type a patient can get transfusion with
    func determineTransfusion() -> String {
        guard let patientBloodType = bloodType
                //pick off strategy using guard statement to check if condition is met
        else {
            return "Patient cannot be transfused because their blood type is unknown"
        }
        // switch for what each blood type can get instead of using multiple conditional statements used switch for these cases since they are not sequential
        switch patientBloodType {
        case .Oplus:
            return "Patient can only be transfused with [O+, O-]"
        case .Ominus:
            return "Patient can only be transfused with [O+, O-, A+, A-. B+, B-, AB+, AB-]"
        case .Aplus:
            return "Patient can only be transfused with [A+, A-, O+, O-]"
        case .Aminus:
            return "Patient can only be transfused with [A-, O-]"
        case .Bplus:
            return "Patient can only be transfused with [B+, B-, O+, O-]"
        case .Bminus:
            return "Patient can only be transfused with [B-, O-]"
        case .ABplus:
            return "Patient can be transfused with any blood type"
        case .ABminus:
            return "Patient can only be transfused with [AB-, O-, A-. B-]"
        }
    }
}

