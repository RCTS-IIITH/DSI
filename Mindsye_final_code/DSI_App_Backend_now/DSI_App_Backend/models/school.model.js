
import mongoose from 'mongoose';

const SchoolSchema = new mongoose.Schema({
    schoolName: {
        type: String,
        required: true
    },
    address: {
        type: String,
        required: true
    },
    UDISE: {
        type: String,
        required: true
    },
    teachers: [{ type: String }],
    assignedProfessional: {
        type: String, // ✅ Save ProfessionalID for display
        default: null,
      },
      assignedProfessionals: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Professional',
        default: [],
          }],
    }, { timestamps: true });

export const School = mongoose.model('School', SchoolSchema);


