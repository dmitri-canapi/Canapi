var customerappdata = "[
{
    "Group": "General",
    "Fields": [
    {
        "Name": "TitleType",
        "Label": "Title Type",
        "Type": "dropdown",
        "Options": [
            "Individual",
            "Partnership",
            "Corporation",
            "LLC"
        ]
    },
    {
        "Name": "NameIfAvailable",
        "Label": "Name if available",
        "Type": "string"
    }
]
},
{
    "Group": "Project Costs",
    "Fields": [
    {
        "Name": "LandPurchase",
        "Label": "Land Purchase or Refinance",
        "Type": "currency"
    },
    {
        "Name": "RealEstatePurchase",
        "Label": "Real Estate Purchase",
        "Type": "currency"
    },
    {
        "Name": "ConstructionHardCost",
        "Label": "Construction Hard Cost",
        "Type": "currency"
    },
    {
        "Name": "ConstruictionSoftCosts",
        "Label": "Construction Soft Costs",
        "Type": "currency"
    },
    {
        "Name": "RealEstateRefinance",
        "Label": "Real Estate Refinance Amount",
        "Type": "currency"
    },
    {
        "Name": "BuildingInterior",
        "Label": "Building Interior Improvement or Repairs",
        "Type": "currency"
    },
    {
        "Name": "WorkingCapital",
        "Label": "Working Capital",
        "Type": "currency"
    },
    {
        "Name": "EquipmentFinancing",
        "Label": "Equipment Financing",
        "Type": "currency"
    },
    {
        "Name": "RealEstateDownPayment",
        "Label": "Real Estate Down Payment Amount",
        "Type": "currency"
    },
    {
        "Name": "TotalLoanRequest",
        "Label": "Total Loan Request",
        "Type": "currency"
    },
    {
        "Name": "PaymentSource",
        "Label": "Source of Down Payment",
        "Type": "radio",
        "Options": [
            "Savings",
            "Gift",
            "Financed",
            "Retirement Funds",
            "Other"
        ]
    },
    {
        "Name": "ifFinanced",
        "Label": "If financed, please outline loan terms",
        "Type": "object",
        "Description": [
            {
                "Name": "Lender",
                "Label": "Lender",
                "Type": "string"
            },
            {
                "Name": "Term",
                "Label": "Term",
                "Type": "number"
            },
            {
                "Name": "Rate",
                "Label": "Rate",
                "Type": "number"
            },
            {
                "Name": "Payment",
                "Label": "Payment",
                "Type": "currency"
            }
        ]
    }
]
},
{
    "Group": "Subject Property",
    "Fields": [
    {
        "Name": "Address",
        "Label": "Address",
        "Type": "string"
    },
    {
        "Name": "YearBuilding",
        "Label": "Year Building Built",
        "Type": "number"
    },
    {
        "Name": "SquareFootage",
        "Label": "Total Square Footage",
        "Type": "number"
    },
    {
        "Name": "PercentOccupied",
        "Label": "Percent Occupied By Owner",
        "Type": "number"
    },
    {
        "Name": "BuildingValue",
        "Label": "Estimated Building value",
        "Type": "currency"
    },
    {
        "Name": "LandArea",
        "Label": "Land Area",
        "Type": "number"
    },
    {
        "Name": "DatePurchasedLand",
        "Label": "Date Purchased Land",
        "Type": "date"
    },
    {
        "Name": "LandFinance",
        "Label": "How Was Land Financed",
        "Type": "object",
        "Description": [
            {
                "Name": "LandFinanceOption",
                "Label": "",
                "Type": "radio",
                "Options": [
                    "Cash",
                    "Loan",
                    "Other"
                ]
            },
            {
                "Name": "LandFinanceOtherDescription",
                "Label": "",
                "Type": "string"
            }
        ]
    },
    {
        "Name": "RealEstateDescription",
        "Label": "Real Estate Description",
        "Type": "object",
        "Description": [
            {
                "Name": "NumberOfBuildings",
                "Label": "# of buildings",
                "Type": "number"
            },
            {
                "Name": "BuildingType",
                "Label": "Type",
                "Type": "radio",
                "Options": [
                    "Free Standing",
                    "Condo Unit"
                ]
            }
        ]
    },
    {
        "Name": "ConstructionType",
        "Label": "Construction Type",
        "Type": "radio",
        "Options": [
            "Brick",
            "Stucco",
            "Concrete Block",
            "Wood Frame"
        ]
    },
    {
        "Name": "ProximityToOtherBusinesses",
        "Label": "Proximity to Other Businesses",
        "Type": "string"
    },
    {
        "Name": "EstimatedValue",
        "Label": "Estimated Value of Real Estate",
        "Type": "currency"
    },
    {
        "Name": "Source",
        "Label": "Source",
        "Type": "string"
    },
    {
        "Name": "EnvironmentalIssues",
        "Label": "Environmental Issues",
        "Type": "string"
    },
    {
        "Name": "ClosingDate",
        "Label": "Closing Date",
        "Type": "date"
    },
    {
        "Name": "EscrowDeadLine",
        "Label": "Escrow DeadLine",
        "Type": "date"
    }
]
},
{
    "Group": "Contact",
    "Fields": [
    {
        "Name": "Escrow",
        "Label": "Escrow Company",
        "Type": "object",
        "Description": [
            {
                "Name": "EscrowCompanyName",
                "Label": "Name",
                "Type": "string"
            },
            {
                "Name": "EscrowPhone",
                "Label": "Phone",
                "Type": "phone"
            }
        ]
    },
    {
        "Name": "Title",
        "Label": "Title Company",
        "Type": "object",
        "Description": [
            {
                "Name": "TitleCompanyName",
                "Label": "Name",
                "Type": "string"
            },
            {
                "Name": "TitleCompanyPhone",
                "Label": "Phone",
                "Type": "phone"
            }
        ]
    },
    {
        "Name": "RealEstate",
        "Label": "Real Estate",
        "Type": "object",
        "Description": [
            {
                "Name": "RealEstateAttorney",
                "Label": "Name",
                "Type": "string"
            },
            {
                "Name": "RealEstateAttorneyPhone",
                "Label": "Phone",
                "Type": "phone"
            }
        ]
    }
]
}
]";