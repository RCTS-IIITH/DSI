import { Report } from '../models/report.model.js';
import { Child } from '../models/child.model.js';
import { ChildData } from '../models/childData.model.js';

// ✅ 1. Get all ChildData entries
export const getAllChildData = async (req, res) => {
    try {
        const data = await ChildData.find({}); // Fetch all child data
        res.status(200).json(data);
    } catch (error) {
        console.error("Error fetching ChildData:", error);
        res.status(500).json({ error: "Failed to fetch child data" });
    }
};

// ✅ 2. Get ChildData filtered by role (e.g., Professional, Parent, Teacher)
export const getChildDataByRole = async (req, res) => {
    const { role, phone } = req.query;

    // Validate required fields
    if (!role) {
        return res.status(400).json({ error: "Role is required for filtering" });
    }

    try {
        let query = {};

        // Apply role-based filtering
        if (role === "Professional") {
            // Professionals see data they submitted
            if (!phone) {
                return res.status(400).json({ error: "Phone is required for Professional role" });
            }
            query["submittedBy.phone"] = phone;
        } else if (role === "Parent") {
            // Parents see data for their child
            const children = await Child.find({ parentPhoneNumber: phone });
            const childNames = children.map(child => child.name);
            query["child_name"] = { $in: childNames };
        } else if (role === "Teacher") {
            // Teachers see data for their school's children
            const children = await Child.find({ school_name: "SchoolA" }); // Replace with dynamic school name
            const childNames = children.map(child => child.name);
            query["child_name"] = { $in: childNames };
        } else {
            return res.status(400).json({ error: "Invalid role specified" });
        }

        // Fetch filtered data
        const data = await ChildData.find(query);
        res.status(200).json(data);
    } catch (error) {
        console.error("Error fetching child data by role:", error);
        res.status(500).json({ error: "Failed to fetch child data" });
    }
};

// ✅ 3. Update ChildData score
export const updateChildDataScore = async (req, res) => {
    const { reportId } = req.params;
    const { manualScore } = req.body;

    if (!reportId || manualScore === undefined) {
        return res.status(400).json({ error: 'reportId and manualScore are required' });
    }

    try {
        // 1. Find the Report by ID
        const report = await Report.findById(reportId);
        if (!report) {
            return res.status(404).json({ error: 'Report not found' });
        }

        // 2. Find the Child by name
        const child = await Child.findOne({ name: report.childsName });
        if (!child) {
            return res.status(404).json({ error: 'Child not found' });
        }

        // 3. Prepare answers from Report
        const answers = JSON.stringify({
            houseAns: report.houseAns,
            personAns: report.personAns,
            treeAns: report.treeAns,
        });

        // 4. Update ChildData using child.name
        const updatedData = await ChildData.findOneAndUpdate(
            { child_name: child.name },
            {
                $set: {
                    score: manualScore,
                    age: child.age,
                    answers: answers,
                    imageurl: report.imageurl,
                    submittedBy: {
                        phone: report.submittedBy?.phone || 'N/A'
                    }
                }
            },
            { new: true, upsert: true }
        );

        return res.json({
            message: 'Score updated successfully',
            data: updatedData
        });
    } catch (error) {
        console.error('Error updating ChildData score:', error);
        return res.status(500).json({ error: 'Failed to update score' });
    }
};