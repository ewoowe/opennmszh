/*******************************************************************************
 * This file is part of OpenNMS(R).
 *
 * Copyright (C) 2009-2012 The OpenNMS Group, Inc.
 * OpenNMS(R) is Copyright (C) 1999-2012 The OpenNMS Group, Inc.
 *
 * OpenNMS(R) is a registered trademark of The OpenNMS Group, Inc.
 *
 * OpenNMS(R) is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * OpenNMS(R) is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OpenNMS(R).  If not, see:
 *      http://www.gnu.org/licenses/
 *
 * For more information contact:
 *     OpenNMS(R) Licensing <license@opennms.org>
 *     http://www.opennms.org/
 *     http://www.opennms.com/
 *******************************************************************************/

package org.opennms.netmgt.provision.service;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.util.Assert;

/**
 * Wrapper object for the doImport method of the Provisioner
 *
 * @author ranger
 * @version $Id: $
 */
public class ImportJob implements Job {
    
    private Provisioner m_provisioner;

    /** Constant <code>KEY="url"</code> */
    protected static final String KEY = "url";
    
    
    /** {@inheritDoc} */
    public void execute(JobExecutionContext context) throws JobExecutionException {

        try {
            String url = (String) context.getJobDetail().getJobDataMap().get(KEY);
            Assert.notNull(url);

            getProvisioner().doImport(url, true);
            
        } catch (Throwable t) {
            throw new JobExecutionException(t);
        }
    }
    
    /**
     * <p>setProvisioner</p>
     *
     * @param provisioner a {@link org.opennms.netmgt.provision.service.Provisioner} object.
     */
    public void setProvisioner(Provisioner provisioner) {
        m_provisioner = provisioner;
    }

    Provisioner getProvisioner() {
        return m_provisioner;
    }
    
}
