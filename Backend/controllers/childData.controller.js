import { Report } from '../models/report.model.js';
import { Child } from '../models/child.model.js';
import { ChildData } from '../models/childData.model.js';
import mongoose from 'mongoose';
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
    try {
        const reportId = req.params.reportId.replace(':', ''); // Remove colon if present

        if (!mongoose.Types.ObjectId.isValid(reportId)) {
            return res.status(400).json({ 
                error: 'Invalid report ID format' 
            });
        }

        const { manualScore, labeledBy } = req.body;

        if (!manualScore) {
            return res.status(400).json({ 
                error: 'Manual score is required' 
            });
        }

        const updatedReport = await Report.findByIdAndUpdate(
            reportId,
            {
                manualScore,
                flagforlabel: true,
                labeledBy,
                labeledAt: new Date()
            },
            { new: true }
        );

        if (!updatedReport) {
            return res.status(404).json({ 
                error: 'Report not found' 
            });
        }

        res.status(200).json({
            message: 'Score updated successfully',
            data: updatedReport
        });

    } catch (error) {
        console.error('Error updating score:', error);
        res.status(500).json({ 
            error: 'Failed to update score',
            details: error.message 
        });
    }
};