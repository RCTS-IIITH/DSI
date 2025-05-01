
import mongoose from 'mongoose';

const ProfessionalSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    Number: {
        type: String,
        required: true
    },
    Address: {
        type: String,
        required: true
    },
    ProfessionalID: {
        type: String,
        required: true
    },
    assignedSchools: {
        type: [String],
        default: [],
      },
}, { timestamps: true });

export const Professional = mongoose.model('Professional', ProfessionalSchema);
