//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace iPortal.App_Data
{
    using System;
    using System.Collections.Generic;
    
    public partial class IPORTAL_VARIABLE_MAPPING
    {
        public int VARIABLE_MAPPING_ID { get; set; }
        public int SDTM_VARIABLE_ID { get; set; }
        public string FILE_VARIABLE { get; set; }
        public int MAPPING_QUALITY { get; set; }
        public int FILE_ID { get; set; }
    
        public virtual IPORTAL_FILE IPORTAL_FILE { get; set; }
        public virtual IPORTAL_SDTM_VARIABLE IPORTAL_SDTM_VARIABLE { get; set; }
    }
}
