import mongoose from 'mongoose';

const ReportSchema = new mongoose.Schema({
  clinicsName: String,
  childsName: String, // Ensure this matches the frontend field name
  age: Number,
  optionalNotes: String,
  flagforlabel: {
    type:Boolean,
    default: false,
  },
  labelling: String,
  imageurl: String,
  houseAns: Object,
  personAns: Object,
  treeAns: Object,
  submittedBy: {
    role: { type: String, required: true },
    phone: { type: String, required: true },
  },
  submittedAt: {
    type: Date,
    default: Date.now,
  },
}, { timestamps: true });

export const Report = mongoose.model('Report', ReportSchema);
