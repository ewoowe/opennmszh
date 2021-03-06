<%--
/*******************************************************************************
 * This file is part of OpenNMS(R).
 *
 * Copyright (C) 2006-2012 The OpenNMS Group, Inc.
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

--%>

<%@page language="java"
	contentType="text/html"
	session="true"
	import="java.util.*,
		org.opennms.web.element.NetworkElementFactory,
		org.opennms.web.admin.nodeManagement.*
	"
%>

<%!
    int interfaceIndex;
    int serviceIndex;
%>

<%
    HttpSession userSession = request.getSession(false);
    List interfaces = null;
    Integer lineItems= new Integer(0);
    
    //EventConfFactory eventFactory = EventConfFactory.getInstance();
    
    interfaceIndex = 0;
    serviceIndex = 0;
    
    if (userSession == null) {
	throw new ServletException("User session is null");
    }

    interfaces = (List) userSession.getAttribute("interfaces.nodemanagement");
    if (interfaces.size() < 1) {
    	throw new NoManagedInterfacesException("element/nodeList.htm");
    }
    if (interfaces == null) {
	throw new ServletException("Session attribute "
				   + "interfaces.nodemanagement is null");
    }
    lineItems = (Integer) userSession.getAttribute("lineItems.nodemanagement");
    if (lineItems == null) {
	throw new ServletException("Session attribute "
				   + "lineItems.nodemanagement is null");
    }
%>

<jsp:include page="/includes/header.jsp" flush="false" >
  <jsp:param name="title" value="管理接口和服务" />
  <jsp:param name="headTitle" value="节点管理" />
  <jsp:param name="headTitle" value="管理" />
  <jsp:param name="location" value="节点管理" />
  <jsp:param name="breadcrumb" value="<a href='admin/index.jsp'>管理</a>" />
  <jsp:param name="breadcrumb" value="节点管理" />
</jsp:include>

<script type="text/javascript" >

  function applyChanges()
  {
      return confirm("你确定要继续吗？这可能需要几分钟，将所做的更改更新到数据库。");
  }
  
  function cancel()
  {
      document.manageAll.action="admin/nodemanagement/index.jsp";
      document.manageAll.submit();
  }
  
  function checkAll()
  {
      for (var c = 0; c < document.manageAll.elements.length; c++)
      {  
          if (document.manageAll.elements[c].type == "checkbox")
          {
              document.manageAll.elements[c].checked = true;
          }
      }
  }
  
  function uncheckAll()
  {
      for (var c = 0; c < document.manageAll.elements.length; c++)
      {  
          if (document.manageAll.elements[c].type == "checkbox")
          {
              
              document.manageAll.elements[c].checked = false;
          }
      }
  }
  
  function updateServices(interfaceIndex, serviceIndexes)
  {
      for (var i = 0; i < serviceIndexes.length; i++)
      {
          document.manageAll.serviceCheck[serviceIndexes[i]].checked = document.manageAll.interfaceCheck[interfaceIndex].checked;
      }
  }
  
  function verifyManagedInterface(interfaceIndex, serviceIndex)
  {
      //if the service is currently unmanged then the user is trying to manage it,
      //but we need to make sure its interface is managed before we let the service be managed
      if (!document.manageAll.interfaceCheck[interfaceIndex].checked)
      {
          if (document.manageAll.serviceCheck[serviceIndex].checked)
          {
              alert("接口上的服务没有被管理。请通过管理接口来管理服务。");
              document.manageAll.serviceCheck[serviceIndex].checked = false;
              return false;
          }
      }
      
      return true;
  }

</script>

<%
        int halfway = 0;
        int midCount = 0;
        int midInterfaceIndex = 0;
        String nodeLabel = null;
  
        if (lineItems.intValue() > 0)
        {
                ManagedInterface firstInterface = (ManagedInterface)interfaces.get(0);
                nodeLabel = NetworkElementFactory.getInstance(getServletContext()).getNodeLabel(firstInterface.getNodeid());
    
                if ( interfaces.size() == 1)
                { 
                        midInterfaceIndex = 1;
                }
                else
                {
                        halfway = lineItems.intValue()/2;
                        for (int interfaceCount = 0; (interfaceCount < interfaces.size()) && (midCount < halfway); interfaceCount++)
                        {
                                if (midCount < halfway)
                                {
                                        midCount++; //one row for each interface
                                        ManagedInterface curInterface = (ManagedInterface)interfaces.get(interfaceCount);
                                        midCount += curInterface.getServiceCount();
                                }
                                else 
                                {
                                        midInterfaceIndex = interfaceCount;
                                        break;
                                }
                        }
                }

                if (midInterfaceIndex < 1)
                        midInterfaceIndex = interfaces.size();
        }
%>

<h2>节点:<%=nodeLabel%></h2>

<hr/>
    
<form method="post" name="manageAll" action="admin/manageNode" onsubmit="return applyChanges();">

  <h3>管理接口和服务</h3>

  <!--
  <p>
    下面列表代表每个管理的接口和服务。'管理'列代表接口或服务的管理状态，选中表示管理，未选中表示不管理。每一个不同的接口有一个暗灰色行并且没有服务栏，该接口上的每个服务被列在下面的浅灰色行。
  </p>

  <p>
    接口的管理状态将自动标记该接口上的每个服务管理状态。如果一个接口无法管理，那么它上面的每个服务也将不能管理。
  </p>
  -->

  <p>
    下面表格表示每个管理和未管理接口和服务组合。在"管理"栏上，如果该服务被选中，则表示处于管理；不选中表示未管理。
  </p>

  <%
    ManagedInterface firstInterface = (ManagedInterface) interfaces.get(0);
    int nodeId = firstInterface.getNodeid();
  %>

  <input type="hidden" name="node" value="<%= nodeId %>"/>

  <input type="submit" value="应用修改"/>
  <input type="button" value="取消" onclick="cancel()"/>
  <input type="button" value="选择所有" onclick="checkAll()"/>
  <input type="button" value="取消全选" onclick="uncheckAll()"/>
  <input type="reset"/>

  <% if (interfaces.size() > 0) { %>
    <table class="standard">
      <tr>
        <td class="standardheader" align="center" width="5%">管理</td>
        <td class="standardheader" align="center" width="10%">接口</td>
        <td class="standardheader" align="center" width="10%">服务</td>
      </tr>
            
      <%=buildManageTableRows(interfaces, 0, midInterfaceIndex)%>
    </table>
  <% } /*end if*/ %>
        
  <%-- See if there is a second column to draw --%>
  <% if (midInterfaceIndex < interfaces.size()) { %>
    <table class="standard">
      <tr>
        <td class="standardheader" align="center" width="5%">管理</td>
        <td class="standardheader" align="center" width="10%">接口</td>
        <td class="standardheader" align="center" width="10%">服务</td>
      </tr>

      <%=buildManageTableRows(interfaces, midInterfaceIndex, interfaces.size())%>
    </table>
  <% } /*end if */ %>
      
  <br/>

  <input type="submit" value="应用修改"/>
  <input type="button" value="取消" onclick="cancel()"/> 
  <input type="button" value="选择所有" onclick="checkAll()"/>
  <input type="button" value="取消全选" onclick="uncheckAll()"/>
  <input type="reset"/>

</form>

<jsp:include page="/includes/footer.jsp" flush="true"/>

<%!
      public String buildManageTableRows(List interfaces, int start, int stop)
      	throws java.sql.SQLException
      {
          StringBuffer rows = new StringBuffer();
          
          for (int i = start; i < stop; i++)
          {
                
                ManagedInterface curInterface = (ManagedInterface)interfaces.get(i);
		String intKey = curInterface.getNodeid() + "-" + curInterface.getAddress();
                StringBuffer serviceArray = new StringBuffer("[");
                String prepend = "";
                for (int serviceCount = 0; serviceCount < curInterface.getServiceCount(); serviceCount++)
                {
                    serviceArray.append(prepend).append(serviceIndex+serviceCount);
                    prepend = ",";
                }
                serviceArray.append("]");

                rows.append(buildInterfaceRow(intKey, 
                                              interfaceIndex, 
                                              serviceArray.toString(), 
                                              (curInterface.getStatus().equals("managed") ? "checked" : ""),
                                              curInterface.getAddress()));
                  
                List interfaceServices = curInterface.getServices();
                for (int k = 0; k < interfaceServices.size(); k++) 
                {
                     ManagedService curService = (ManagedService)interfaceServices.get(k);
                     String serviceKey = curInterface.getNodeid() + "-" + curInterface.getAddress() + "-" + curService.getId();
                     rows.append(buildServiceRow(serviceKey,
                                                 interfaceIndex,
                                                 serviceIndex,
                                                 (curService.getStatus().equals("managed") ? "checked" : ""),
                                                 curInterface.getAddress(),
                                                 curService.getName()));
                     serviceIndex++;
                
                } /*end k for */
                
                interfaceIndex++;
                
          } /* end i for */
          
          return rows.toString();
      }
      
      public String buildInterfaceRow(String key, int interfaceIndex, String serviceArray, String status, String address)
      {
          StringBuffer row = new StringBuffer( "<tr>");
          /*
          row.append("<td class=\"standardheaderplain\" width=\"5%\" align=\"center\">");
          row.append("<input type=\"checkbox\" name=\"interfaceCheck\" value=\"").append(key).append("\" onclick=\"javascript:updateServices(" + interfaceIndex + ", " + serviceArray + ")\" ").append(status).append(" >");
          row.append("</td>").append("\n");
          row.append("</td>").append("\n");
          row.append("<td class=\"standardheaderplain\" width=\"10%\" align=\"center\">");
          row.append(address);
          row.append("</td>").append("\n");
          row.append("<td class=\"standardheaderplain\" width=\"10%\" align=\"center\">").append("&nbsp;").append("</td></tr>").append("\n");
          */ 
          row.append("<input type=\"hidden\" name=\"interfaceCheck\" value=\"").append(key).append("\" onclick=\"javascript:updateServices(" + interfaceIndex + ", " + serviceArray + ")\" ").append(status).append(" >");
          return row.toString();
      }
      
      public String buildServiceRow(String key, int interfaceIndex, int serviceIndex, String status, String address, String service)
      {
          StringBuffer row = new StringBuffer( "<tr>");
          
          row.append("<td class=\"standard\" width=\"5%\" align=\"center\">");
          row.append("<input type=\"checkbox\" name=\"serviceCheck\" value=\"").append(key).append("\" onclick=\"javascript:verifyManagedInterface(" + interfaceIndex + ", " + serviceIndex + ")\" ").append(status).append(" >");
          row.append("</td>").append("\n");
          row.append("<td class=\"standard\" width=\"10%\" align=\"center\">").append(address).append("</td>").append("\n");
          row.append("<td class=\"standard\" width=\"10%\" align=\"center\">").append(service).append("</td></tr>").append("\n");
          
          return row.toString();
      }
%>
