
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
    workEmail: {
        type: String,
        required: true,
        validate: {
          validator: function(v) {
            return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v); // Require valid format
          },
          message: props => `${props.value} is not a valid email address!`
        }
      },
    ProfessionalID: {
        type: String,
        required: true
    },
    assignedSchools: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'School'
    }]
}, { timestamps: true });

export const Professional = mongoose.model('Professional', ProfessionalSchema);
