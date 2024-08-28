import Foundation
import TPPDF
import AppKit
import OSLog
import Algorithms

// MARK: - Prepare
let logger = Logger()

let tempDir = URL(filePath: NSTemporaryDirectory())
guard let outputUrl = URL(string: "Philip Niedertscheider CV.pdf", relativeTo: tempDir) else {
    logger.error("Failed to create output path")
    exit(1)
}

// MARK: - Build
let document = PDFDocument(layout: .init(
    size: PDFPageFormat.a4.size,
    margin: EdgeInsets(top: 32, left: 32, bottom: 32, right: 32),
    space: (header: 4, footer: 4)
))
document.info.title = "Curriculum Vitae of Philip Niedertscheider"
document.info.author = "Philip Niedertscheider"
document.info.subject = "Professional profile of Philip Niedertscheider showcasing previous experiences and skillset"
document.info.keywords = ["Curriculum Vitae", "CV", "Resume", "Mobile", "App", "Developer"]
document.info.allowsPrinting = true
document.info.allowsCopying = true

// Define text styles
extension PDFTextStyle {
    static let title: PDFTextStyle = {
        let style = PDFTextStyle(name: "Title")
        style.font = Font(name: "Georgia", size: 28)
        style.color = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        return style
    }()

    static let subtitle: PDFTextStyle = {
        let style = PDFTextStyle(name: "Subtitle")
        style.font = Font(name: "Georgia", size: 10)
        return style
    }()

    static let heading: PDFTextStyle = {
        let style = PDFTextStyle(name: "Heading")
        style.font = Font(name: "Georgia Bold", size: 14)
        return style
    }()

    static let heading2: PDFTextStyle = {
        let style = PDFTextStyle(name: "Heading 2")
        style.font = Font(name: "Georgia Bold", size: 12)
        return style
    }()

    static let heading2_regular: PDFTextStyle = {
        let style = PDFTextStyle(name: "Heading 2")
        style.font = Font(name: "Georgia", size: 12)
        return style
    }()

    static let heading3: PDFTextStyle = {
        let style = PDFTextStyle(name: "Heading 3")
        style.font = Font(name: "Georgia Bold", size: 10)
        return style
    }()

    static let footer: PDFTextStyle = {
        let style = PDFTextStyle(name: "Footer")
        style.font = Font(name: "Georgia Italic", size: 8)
        return style
    }()

}

// Add text styles to document
document.add(style: .title)
document.add(style: .subtitle)
document.add(style: .heading)
document.add(style: .heading2)
document.add(style: .heading2_regular)
document.add(style: .heading3)

// Set the default body style
document.set(font: Font(name: "Georgia", size: 10)!)

// Configure the footer
let footerNote = NSMutableAttributedString()
footerNote.append(NSAttributedString(string: "This curriculum vitae is a showcase of using my PDF generator framework "))
footerNote.append(NSAttributedString(string: "TPPDF", attributes: [
    .link: "https://github.com/techprimate/TPPDF",
    .underlineStyle: NSUnderlineStyle.byWord,
    .underlineColor: Color.blue
]))
footerNote.append(NSAttributedString(string: ".\nThe full source code is available at "))
footerNote.append(NSAttributedString(string: "github.com/philprime/cv", attributes: [
    .link: "https://github.com/philprime/cv",
    .underlineStyle: NSUnderlineStyle.byWord,
    .underlineColor: Color.blue
]))
footerNote.append(NSAttributedString(string: "."))
footerNote.addAttributes([
    .font: PDFTextStyle.footer.font!
], range: .init(location: 0, length: footerNote.length))
document.add(.footerLeft, attributedText: footerNote)

let paginationFormatter = NumberFormatter()
document.pagination = .init(
    container: .footerRight,
    style: .customNumberFormat(
        template: "%@ of %@",
        formatter: paginationFormatter
    ),
    textAttributes: [
        .font: Font(name: "Georgia", size: 10)!
    ]
)

// Create the title section
document.add(.contentCenter, textObject: .init(
    text: "Philip Karl Niedertscheider",
    style: .title
))
document.add(space: 4)
document.add(.contentCenter, textObject: .init(
    text: [
        "phil@techprimate.com",
        "philprime.dev",
        "linkedin.com/in/philipniedertscheider",
        "github.com/philprime"
    ].joined(separator: " • "),
    style: .subtitle
))
document.add(space: 10)

// Create a helper function for the header
func createHeader(text: String) {
    document.add(space: 10)
    document.add(textObject: .init(text: text, style: .heading))
    document.addLineSeparator(style: .init(
        type: .full,
        color: .init(white: 0.25, alpha: 1.0),
        width: 0.25
    ))
    document.add(space: 6)
}

// Section - Profile
createHeader(text: "Profile")
document.add(text: "Highly skilled and passionate software developer with over 10 years of experience specializing in mobile app development, distributed back-end development, and deployment process automation. Proven track record of leading teams, founding startups, and managing related administrative responsibilities of building companies. Strongly motivated to deliver excellence, with a keen focus on clean, solution-oriented work and clear communication. Proficient at economic thinking, with a robust background in both technical and business domains. Self-taught and continuously learning, with a strong advocation for open-source software, especially as the founder and lead maintainer of TPPDF, a Swift framework with over 700 stars on GitHub.")

// Section - Professional Experience
createHeader(text: "Professional Experience")

func addProfessionalExperience(
    company: String? = nil,
    role: String,
    from: String,
    to: String? = nil,
    responsibilities: [String]
) {
    let columnLeft = PDFSectionColumn(width: 0.6)
    if let company = company {
        columnLeft.add(textObject: .init(text: company, style: .heading2))
        columnLeft.add(textObject: .init(text: role, style: .heading3))
    } else {
        columnLeft.add(textObject: .init(text: role, style: .heading2))
    }

    let columnRight = PDFSectionColumn(width: 0.4)
    let timeRangeText: PDFSimpleText
    if let to = to {
        timeRangeText = .init(text: "\(from) — \(to)", style: .heading2_regular)
    } else {
        timeRangeText = .init(text: from, style: .heading2_regular)
    }
    columnRight.add(.right, textObject: timeRangeText)

    let section = PDFSection([columnLeft, columnRight])
    document.add(section: section)

    let list = PDFList(indentations: [
        (pre: 4.0, past: 8.0)
    ])
    for responsibility in responsibilities {
        let item = PDFListItem(symbol: .custom(value: "\u{2022}"), content: responsibility)
        list.addItem(item)
    }
    document.add(list: list)

    document.add(space: 8)
}

addProfessionalExperience(
    company: "kula app GmbH",
    role: "Founder, Managing Director, CTO",
    from: "July 2022",
    to: "Present",
    responsibilities: [
        "Led the development of a fully automated app deployment system, to combine user data, code-generation and proprietary automation technologies to manage individualized apps at scale, while reducing app deployment time from weeks to days.",
        "Managed all aspects of cloud infrastructure, backend software, and automation technology while overseeing strategic and economic aspects of the startup.",
        "Developed scalable, secure mobile apps with deep expertise in Swift, SwiftUI and UIKit.",
        "Strong background in mobile app security, backed by academic research and extensive hands-on experience.",
        "Continuously optimized cloud infrastructure to handle increasing loads using containerisation, cloud orchestration (Kubernetes, AWS) and monitoring solutions (Grafana, Prometheus), without compromising performance, availability or security, following along best practices (AWS Well-Architectured Framework Review, WAFR).",
        "Led implementation of Continuous Integration and Continuous Delivery (CI/CD) pipelines using GitHub Actions, integrating automated testing and deployment processes.",
        "Applied LLMs like OpenAI’s GPT API to make the app-building process accessible to non-technical users.",
        "Active contributor and lead maintainer of multiple open-source frameworks, including founding and leading the publicly-funded platform OnLaunch, built as an web application (Next.JS) with its native clients written for Android (Kotlin), Flutter (Dart) and iOS (Swift).",
        "Proficient in breaking down complex problems into smaller, manageable work packages to implement a collaborative, autonomous work environment, empowering team members to achieve goals independently, iteratively and in parallel, while providing mentorship and advice.",
        "Experienced in managing projects within small, dynamic teams where frequent changes required a high degree of flexibility.",
        "Collaborated with non-technical roles such as sales, marketing, and customer support to align technical solutions with business objectives, while also developing internal tools to enhance organisational efficiency.",
        "Taught non-technical employees complex technical concepts and supported them in learning new technologies.",
    ]
)
addProfessionalExperience(
    company: "techprimate GmbH",
    role: "Founder, Managing Director, CTO",
    from: "August 2022",
    to: "Present",
    responsibilities: [
        "Management of cloud hosting solutions (email, websites)",
        "Research and development lead for applications for iOS and macOS (Swift)",
        "Design and implementation of back-end software (Node.JS, Typescript)",
        "Consultant for mobile app development strategies and architectures",
        "Lead-maintainer of Free Open Source Software (FOSS) projects written in Swift",
        "Setup and maintenance of Continuous Integration/Continuous Deployment (CI/CD) processes",
    ]
)
addProfessionalExperience(
    company: "WolfVision GmbH",
    role: "Senior iOS/macOS Developer",
    from: "August 2020",
    to: "September 2022",
    responsibilities: [
        "Research and development of cross-platform applications for Apple platforms (iOS/macOS)",
        "Refactoring of individual iOS and macOS apps into a shared, clean-architecture using the VIPER pattern",
        "Setup and management of Continuous Integration/Continuous Deployment infrastructure using GitLab Runner with self-hosted infrastructure",
        "Planning and mentoring for software architecture design",
    ]
)
addProfessionalExperience(
    company: "techprimate GmbH & Co. KG",
    role: "Founder, CTO",
    from: "July 2020",
    to: "August 2022",
    responsibilities: [
        "Research and development lead for applications for iOS and macOS (Swift)",
        "Design and implementation of back-end software (Node.JS, Typescript)",
        "Consultant for mobile app development",
        "Lead-maintainer of Free Open Source Software (FOSS) projects written in Swift",
        "Setup and maintenance of Continuous Integration/Continuous Deployment (CI/CD) processes",
    ]
)
addProfessionalExperience(
    company: "fusonic GmbH",
    role: "Software Developer Intern",
    from: "July 2020",
    to: "August 2020",
    responsibilities: [
        "Development of back-end applications (ASP.NET) using REST and gRPC",
        "Research, analysis and presentation of application performance tracking using Sentry",
        "Collaborating with a team of developers using agile methods (SCRUM)",
    ]
)
addProfessionalExperience(
    company: "techprimate GmbH & Co. KG",
    role: "Founder, Managing Director, CTO",
    from: "July 2018",
    to: "August 2020",
    responsibilities: [
        "Technical co-founder and managing director of mobile app development agency",
        "Product development and project management team lead (CTO)",
        "Research and development lead for applications for iOS and macOS (Swift)",
        "Design and implementation of back-end software (Node.JS, Typescript)",
        "Introduction and lead of project management (SCRUM)",
        "Customer dialogue and contract negotiations",
        "Infrastructure management (Docker)",
        "Lead maintainer of Free Open Source Software (FOSS) projects",
        "Setup and maintenance of Continuous Integration/Continuous Deployment (CI/CD) processes",
        "Establishment and legal management of an Austrian limited liability corporation (GmbH)",
    ]
)
addProfessionalExperience(
    company: "Christian Niedertscheider Systemplan",
    role: "System Administrator",
    from: "June 2017",
    to: "December 2022",
    responsibilities: [
        "System and server infrastructure management",
        "Planning and implementation of IT processes",
        "Technical administration and support",
    ]
)
addProfessionalExperience(
    company: "Austrian Red Cross",
    role: "Paramedic (Compulsory Civilian Service)",
    from: "September 2016",
    to: "July 2017",
    responsibilities: [
        "Trained paramedic in accordance with the paramedic training regulations (San-AV), BGB. II Nr. 420/0203"
    ]
)
addProfessionalExperience(
    role: "Independent Software Developer",
    from: "September 2015",
    to: "July 2018",
    responsibilities: [
        "Research and development of mobile applications for iOS (Swift) and backend applications (Node.JS)",
        "Migration from UIKit to CoreGraphics and CoreText for PDF document generation on iOS and macOS",
        "Founding and maintenance of Free Open Source Software (FOSS) as Swift Frameworks",
    ]
)
addProfessionalExperience(
    company: "Consilio Information Management GmbH",
    role: "Junior Software Developer",
    from: "July 2016",
    to: "August 2016",
    responsibilities: [
        "Research and development of mobile applications for iOS (Swift)",
        "App release management via the Apple App Store",
        "Setup of shared code signing certificate management using fastlane (Ruby)",
    ]
)
addProfessionalExperience(
    company: "Consilio Information Management GmbH",
    role: "Software Developer Intern",
    from: "August 2015",
    responsibilities: [
        "Research and development of mobile applications for iOS (Swift)",
        "App release management via the Apple App Store",
    ]
)
addProfessionalExperience(
    company: "Consilio Information Management GmbH",
    role: "Software Developer Intern",
    from: "July 2014",
    responsibilities: [
        "Project setup and development of mobile applications for iOS (Objective-C, Swift)",
        "Design and client-side implementation of API interface",
        "Documentation management for app publishing process (iTunes Connect)",
    ]
)

// Section - Skills
createHeader(text: "Skills")

func addSkillset(name: String, skills: [String]) {
    document.add(textObject: .init(text: name, style: .heading3))

    let list = PDFList(indentations: [
        (pre: 4.0, past: 8.0)
    ])
    for skill in skills {
        let item = PDFListItem(symbol: .custom(value: "\u{2022}"), content: skill)
        list.addItem(item)
    }
    document.add(list: list)
}

addSkillset(name: "Mobile App Development", skills: [
    "Swift, Objective-C (10 years)",
    "SwiftUI, UIKit, AppKit",
    "Deep understanding of operating systems iOS and macOS",
    "Build, deployment & release management with App Store Connect",
    "Building complex deployment pipelines using fastlane (Ruby)",
    "Publishing of Swift libraries using Swift Package Manager and Cocoapods",
    "Performance profiling, manual crash symbolication and analysis, binary decompilation (for security research) using Xcode Instruments",
    "Architectural patterns like MVVM, Redux, VIPER",
])
addSkillset(name: "Back-end Development", skills: [
    "Node.JS mit Typescript (7 years)",
    "Nest.JS, Next.JS, React",
    "MongoDB, PostgreSQL (5 years)",
    "MongoDB Atlas App Services / Realm",
    "ChakraUI, TailwindCSS",
    "Distributed systems using Kafka, Redis (4 years)",
])
addSkillset(name: "Cloud Operations (DevOPs)", skills: [
    "Implementation of scalable cloud solutions using Amazon Web Services (AWS)",
    "Deployment of highly-scalable infrastructure using Kubernetes & Docker containerisation",
    "Infrastructure-as-Code (IaC) using Pulumi",
    "Setup of Continuous Integration / Continuous Delivery (CI/CD) infrastructure and processes (GitHub Actions, GitLab Runner, Bitrise)",
    "Securing remote infrastructure using VPN technologies like Tailscale",
])
addSkillset(name: "Open Source Project Management", skills: [
    "Issue Management",
    "Code Review",
    "Quality Assurance",
    "Release Management",
])
addSkillset(name: "Technical Conception & Documentation", skills: [
    "Design of distributed systems (Publish-Subscribe, Event-Driven)",
    "Implementation of micro-service architectures",
    "Planning and maintenance of future-proof web application program interfaces (REST API)",
])

// Section - Education
createHeader(text: "Academic Education")

func addEducation(
    institution: String,
    from: Int,
    to: Int,
    program: String,
    thesis: String? = nil
) {
    let columnLeft = PDFSectionColumn(width: 0.8)
    columnLeft.add(textObject: .init(text: institution, style: .heading2))

    let columnRight = PDFSectionColumn(width: 0.2)
    columnRight.add(.right, textObject: .init(
        text: "\(from) — \(to)",
        style: .heading2_regular
    ))
    
    let section = PDFSection([columnLeft, columnRight])
    document.add(section: section)
    document.add(text: program)
    document.add(space: 4)
}

addEducation(
    institution: "TU Wien Innovation Incubation Center (i²c)",
    from: 2021,
    to: 2022,
    program: "Startup Incubation Program"
)
addEducation(
    institution: "Vienna University of Technology",
    from: 2017,
    to: 2022,
    program: "Bachelor’s of Science in Software & Information Engineering",
    thesis: "Developing security guidelines for iOS app developers"
)
addEducation(
    institution: "AFS Intercultural Program",
    from: 2012,
    to: 2013,
    program: "High School student exchange program in the United States of America (USA)"
)
addEducation(
    institution: "Höhere Technische Lehranstalt Bregenz",
    from: 2010,
    to: 2016,
    program: "Matura in Mechanical Engineering for Automation Technologies"
)

// Section - Languages
createHeader(text: "Languages")
let languages = [
    "German (Native)",
    "English (Fluent)",
]

let languagesNumberOfColumns = 4
var languagesColumns = [PDFSectionColumn]()
for chunk in languages.evenlyChunked(in: languagesNumberOfColumns) {
    let list = PDFList(indentations: [
        (pre: 4.0, past: 8.0)
    ])
    for interest in chunk {
        let item = PDFListItem(symbol: .custom(value: "\u{2022}"), content: interest)
        list.addItem(item)
    }
    let column = PDFSectionColumn(width: 1.0 / CGFloat(languagesNumberOfColumns))
    column.add(list: list)
    languagesColumns.append(column)
}
let languagesSection = PDFSection(languagesColumns)
document.add(section: languagesSection)


// Section - Other Qualifications
createHeader(text: "Other Qualifications & Achievements")

let otherQualifications = [
    "Drivers Licenses: A2 and B",
    "CodersRank Top 1% Worldwide (profile.codersrank.io/user/philprime, August 2024)",
    "CodersRank Top 1 Swift Developer Austria (profile.codersrank.io/user/philprime, August 2024)",
    "One of 1,000 developers invited to Apple’s Worldwide Developer Conference (WWDC) 2022",
]
let otherQualificationsList = PDFList(indentations: [(pre: 4.0, past: 8.0)])
for qualification in otherQualifications {
    let item = PDFListItem(symbol: .custom(value: "\u{2022}"), content: qualification)
    otherQualificationsList.addItem(item)
}
document.add(list: otherQualificationsList)

// Section - Personal Interests
createHeader(text: "Personal Interests")
let interests = [
    "Photography",
    "Cooking",
    "Mountain Biking",
    "Motor Sports",
    "DIY Crafting",
    "3D Printing",
    "Learning Japanese"
]

let personalInterestsNumberOfColumns = 4
var personalInterestsColumns = [PDFSectionColumn]()
for chunk in interests.evenlyChunked(in: personalInterestsNumberOfColumns) {
    let list = PDFList(indentations: [
        (pre: 4.0, past: 8.0)
    ])
    for interest in chunk {
        let item = PDFListItem(symbol: .custom(value: "\u{2022}"), content: interest)
        list.addItem(item)
    }
    let column = PDFSectionColumn(width: 1.0 / CGFloat(personalInterestsNumberOfColumns))
    column.add(list: list)
    personalInterestsColumns.append(column)
}
let personalInterestsSection = PDFSection(personalInterestsColumns)
document.add(section: personalInterestsSection)

// MARK: - Generate
logger.log("Generating PDF Document to path: \(outputUrl.absoluteString)")
let generator = PDFGenerator(document: document)
do {
    try generator.generate(to: outputUrl)
} catch {
    logger.error("Failed to generate PDF document: \(error)")
    exit(1)
}

// MARK: - Finish
logger.log("Opening generated PDF document in system viewer app...")
guard NSWorkspace.shared.open(outputUrl) else {
    logger.error("Failed to open generated PDF document in system viewer app")
    exit(1)
}


