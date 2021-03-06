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
	import="org.opennms.netmgt.config.users.*,
	        org.opennms.netmgt.config.*,
		java.util.*"
%>

<%
	UserManager userFactory;
  	Map users = null;
	HashMap usersHash = new HashMap();
	String curUserName = null;
	
	try
    	{
		UserFactory.init();
		userFactory = UserFactory.getInstance();
      		users = userFactory.getUsers();
	}
	catch(Throwable e)
	{
		throw new ServletException("User:list " + e.getMessage());
	}

	Iterator i = users.keySet().iterator();
	while (i.hasNext()) {
		User curUser = (User)users.get(i.next());
		usersHash.put(curUser.getUserId(), curUser.getFullName());
	}

%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<jsp:include page="/includes/header.jsp" flush="false">
	<jsp:param name="title" value="角色配置" />
	<jsp:param name="headTitle" value="查看" />
	<jsp:param name="headTitle" value="角色" />
	<jsp:param name="headTitle" value="管理" />
	<jsp:param name="breadcrumb" value="<a href='admin/index.jsp'>管理</a>" />
	<jsp:param name="breadcrumb" value="<a href='admin/userGroupView/index.jsp'>用户，组和角色</a>" />
	<jsp:param name="breadcrumb" value="<a href='admin/userGroupView/roles'>角色列表</a>" />
	<jsp:param name="breadcrumb" value="查看角色" />
</jsp:include>


<!--  swiped this and images/new.gif from webcalendar.sf.net -->
<style type="text/css">

.new {
  border-width: 0px;
  float: right;
}

.date {
  border-width: 0px;
  float: left;
}

</style>

<script type="text/javascript" >

	function changeDisplay() {
		document.displayForm.submit();
	}
	
	function prevMonth() {
		document.prevMonthForm.submit();
	}
	
	function nextMonth() {
		document.nextMonthForm.submit();
	}
	
	function addEntry(date) {
		document.addEntryForm.date.value = date;
		document.addEntryForm.submit();
		
	}
	
	function editEntry(schedIndex, timeIndex) {
		document.editEntryForm.schedIndex.value = schedIndex;
		document.editEntryForm.timeIndex.value = timeIndex;
		document.editEntryForm.submit();
	}

</script>

<h3>查看角色</h3>

<table>
  <tr>
    <th>名称</th>
	<td>${role.name}</td>
    <th>当前值班</th>
	<td>
	  <c:forEach var="scheduledUser" items="${role.currentUsers}">
		<c:set var="fullName"><%= usersHash.get(pageContext.getAttribute("scheduledUser").toString()) %></c:set>
		<span title="${fullName}">${scheduledUser}</span>
	  </c:forEach>	
	</td>
  </tr>
  
  <tr>
    <th>监督</th>
	<td>
	  <c:set var="supervisorUser">${role.defaultUser}</c:set>
	  <c:set var="fullName"><%= usersHash.get(pageContext.getAttribute("supervisorUser").toString()) %></c:set>
	  <span title="${fullName}">${role.defaultUser}</span></td>
    <th>组</th>
	<td>${role.membershipGroup}</td>
  </tr>
  
  <tr>
    <th>说明</th>
	<td colspan="3">${role.description}</td>
  </tr>
</table>


		<form action="<c:url value='${reqUrl}'/>" method="post" name="editForm">
			<input type="hidden" name="operation" value="editDetails"/>
			<input type="hidden" name="role" value="${role.name}"/>
			<input type="submit" value="编辑详细" />
		</form>

		<form action="<c:url value='${reqUrl}'/>" method="post" name="doneForm">
			<input type="submit" value="完成" />
		</form>

<h3>角色值班表</h3>


				<form action="<c:url value='${reqUrl}'/>" method="post" name="prevMonthForm">
					<input type="hidden" name="operation" value="view"/>
					<input type="hidden" name="role" value="${role.name}"/>
					<input type="hidden" name="month" value="<fmt:formatDate value='${calendar.previousMonth}' type='date' pattern='MM-yyyy'/>"/>
				</form>
				<form action="<c:url value='${reqUrl}'/>" method="post" name="nextMonthForm">
					<input type="hidden" name="operation" value="view"/>
					<input type="hidden" name="role" value="${role.name}"/>
					<input type="hidden" name="month" value="<fmt:formatDate value='${calendar.nextMonth}' type='date' pattern='MM-yyyy'/>"/>
				</form>
				<form action="<c:url value='${reqUrl}'/>" method="post" name="addEntryForm">
					<input type="hidden" name="operation" value="addEntry"/>
					<input type="hidden" name="role" value="${role.name}"/>
					<input type="hidden" name="date"/>
				</form>
				<form action="<c:url value='${reqUrl}'/>" method="post" name="editEntryForm">
					<input type="hidden" name="operation" value="editEntry"/>
					<input type="hidden" name="role" value="${role.name}"/>
					<input type="hidden" name="schedIndex"/>
					<input type="hidden" name="timeIndex"/>
				</form>

			<table>
			  <caption>
				<a href="javascript:prevMonth()">&#139;&#139;&#139;</a>&nbsp;
				<b>${calendar.monthAndYear}</b>&nbsp;
				<a href="javascript:nextMonth()">&#155;&#155;&#155;</a>
			  </caption>
				<tr>
				  <c:forEach var="day" items="${calendar.weeks[0].days}">
				    <th>${day.dayOfWeek}</th>
				  </c:forEach>
				</tr>
				<c:forEach var="week" items="${calendar.weeks}">
				  <tr>
					<c:forEach var="day" items="${week.days}">
					  <td>
					    <c:if test="${calendar.month == day.month}">
						  <c:set var="newHref">javascript:addEntry('<fmt:formatDate value='${day.date}' type='date' pattern='MM-dd-yyyy'/>')</c:set>
						  <b class="date"><c:out value="${day.dayOfMonth}"/></b><a class="new" href="<c:out value='${newHref}' escapeXml='false'/>"><img border=0 src="images/new.gif"/></a>
						  <br/>
						  <c:forEach var="entry" items="${day.entries}">
							<fmt:formatDate value="${entry.startTime}" type="time" pattern="HH:mm"/>:<c:forEach var="owner" items="${entry.labels}"><c:set var="curUserName"><c:out value="${owner.user}"/></c:set><c:set var="fullName"><%= usersHash.get((String)pageContext.getAttribute("curUserName")) %></c:set><c:set var="editHref">javascript:editEntry(<c:out value="${owner.schedIndex}"/>,<c:out value="${owner.timeIndex}"/>)</c:set>&nbsp;<c:choose><c:when test="${owner.supervisor}">unscheduled</c:when><c:otherwise><a href="<c:out value='${editHref}' escapeXml='false'/>" title="<c:out value='${fullName}'/>"><c:out value="${owner.user}"/></a></c:otherwise></c:choose></c:forEach><br/>
						  </c:forEach>
					    </c:if>
					  </td>
					</c:forEach>
				  </tr>
				</c:forEach>
			</table>

		<form action="<c:url value='${reqUrl}'/>" method="post" name="doneForm">
			<input type="submit" value="完成" />
		</form>


<jsp:include page="/includes/footer.jsp" flush="false" />
