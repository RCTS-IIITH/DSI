import { User } from '../models/user.model.js';
import { Professional } from '../models/professional.model.js';
import { normalizeRole } from '../constants/roles.js';

// Middleware to enforce organization context and data isolation
export const requireOrganizationContext = async (req, res, next) => {
  try {
    // Handle both POST (body) and GET (query) requests
    const phone = req.body.phone || req.query.phone || req.body.phoneNumber || req.query.phoneNumber;
    const role = req.body.role || req.query.role || req.body.usertype || req.query.usertype;
    
    if (!phone || !role) {
      return res.status(400).json({ 
        success: false, 
        message: 'Phone and role are required for organization context' 
      });
    }

    let user = null;
    let organizationId = null;

    // Normalize role names for consistent lookup
    const normalizedRole = normalizeRole(role);
    
    // Get organization context based on role
    if (normalizedRole === 'OrganizationAdmin' || normalizedRole === 'NGOAdmin' || normalizedRole === 'SchoolAdmin') {
      user = await User.findOne({ number: phone, role: normalizedRole });
      if (!user) {
        return res.status(404).json({ 
          success: false, 
          message: 'User not found' 
        });
      }
      organizationId = user.organizationId;
    } else if (normalizedRole === 'Professional') {
      const professional = await Professional.findOne({ Number: phone });
      if (!professional) {
        return res.status(404).json({ 
          success: false, 
          message: 'Professional not found' 
        });
      }
      organizationId = professional.organizationId;
    } else if (normalizedRole === 'Teacher' || normalizedRole === 'Parent') {
      // For teachers and parents, get organization from their school
      const { Teacher } = await import('../models/teacher.model.js');
      const { Child } = await import('../models/child.model.js');
      const { School } = await import('../models/school.model.js');
      
      if (normalizedRole === 'Teacher') {
        const teacher = await Teacher.findOne({ phone: phone }).populate('schoolID');
        if (teacher && teacher.schoolID) {
          organizationId = teacher.schoolID.organizationId;
        }
      } else if (normalizedRole === 'Parent') {
        const child = await Child.findOne({ parentPhoneNumber: phone });
        if (child) {
          const school = await School.findById(child.schoolID);
          organizationId = school?.organizationId;
        }
      }
    }

    if (!organizationId) {
      return res.status(403).json({ 
        success: false, 
        message: 'No organization context found for user' 
      });
    }

    // Attach organization context to request
    req.organizationId = organizationId;
    req.userContext = { phone, role, organizationId };
    
    next();
  } catch (error) {
    console.error('Organization context middleware error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server error in organization context', 
      error: error.message 
    });
  }
};

// Middleware to ensure user can only access their organization's data
export const enforceOrganizationBoundary = (req, res, next) => {
  const userOrgId = req.organizationId;
  const targetOrgId = req.params.organizationId || req.query.organizationId || req.body.organizationId;

  // If no target organization specified, use user's organization
  if (!targetOrgId) {
    req.targetOrganizationId = userOrgId;
    return next();
  }

  // Check if user is trying to access data outside their organization
  if (targetOrgId !== userOrgId.toString()) {
    return res.status(403).json({ 
      success: false, 
      message: 'Access denied: Cannot access data outside your organization' 
    });
  }

  req.targetOrganizationId = targetOrgId;
  next();
};

// Helper function to get organization context for any user
export const getOrganizationContext = async (phone, role) => {
  try {
    const normalizedRole = normalizeRole(role);
    
    if (normalizedRole === 'OrganizationAdmin' || normalizedRole === 'NGOAdmin' || normalizedRole === 'SchoolAdmin') {
      const user = await User.findOne({ number: phone, role: normalizedRole });
      return user?.organizationId;
    } else if (normalizedRole === 'Professional') {
      const professional = await Professional.findOne({ Number: phone });
      return professional?.organizationId;
    }
    // For teachers and parents, organization comes from school
    return null;
  } catch (error) {
    console.error('Error getting organization context:', error);
    return null;
  }
};
