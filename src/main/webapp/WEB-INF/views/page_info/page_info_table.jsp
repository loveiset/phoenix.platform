<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="/META-INF/suren.tld" prefix="su" %>
<%String basePath=request.getContextPath(); %>
<!DOCTYPE html>
<html lang="zh-cn">
<head>
<title>页面集</title>
<su:link href="/static/bootstrapValidator/css/bootstrapValidator.css"></su:link>
<su:script src="/static/bootstrapValidator/js/bootstrapValidator.js"></su:script>
<su:script src="/static/autotest/msgTip.js"></su:script>
<su:script src="/static/jquery.serializejson.min.js"></su:script>
<su:script src="/static/autotest/form.js"></su:script>
<su:link href="/static/bootstrap-table/bootstrap-table.css"></su:link>
<su:script src="/static/bootstrap-table/bootstrap-table.min.js"></su:script>
</head>
<body>
<nav class="navbar navbar-default" role="navigation">
	<div class="container-fluid">
		<!-- Brand and toggle get grouped for better mobile display -->
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed"
				data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
				<span class="sr-only">Toggle navigation</span> <span
					class="icon-bar"></span> <span class="icon-bar"></span> <span
					class="icon-bar"></span>
			</button>
			<c:if test="${!empty pageInfo.id }">
			<a class="navbar-brand" href="test?id=${pageInfo.id }">刷新</a>
			</c:if>
		</div>

		<!-- Collect the nav links, forms, and other content for toggling -->
		<div class="collapse navbar-collapse"
			id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li class="dropdown"><a href="#" class="dropdown-toggle"
					data-toggle="dropdown" data-step="3" data-intro="查看列表" data-position="right">列表 <span class="caret"></span></a>
					<ul class="dropdown-menu" role="menu">
						<li><a href="<%=basePath %>/project/edit?id=${projectId}">当前项目</a></li>
						<li><a href="<%=basePath %>/project/list">项目列表</a></li>
						<li class="divider"></li>
						<li><a href="<%=basePath %>/page_info/list?projectId=${projectId}">页面集列表</a></li>
						<li><a href="<%=basePath %>/data_source_info/list?projectId=${projectId}">数据源列表</a></li>
						<li><a href="<%=basePath %>/suite_runner_info/list?projectId=${projectId}">测试套件列表</a></li>
					</ul>
				</li>
			</ul>
			<ul class="nav navbar-nav navbar-right">
				<c:if test="${!empty pageInfo.id }">
				<li><a href="download?id=${pageInfo.id }" data-step="4" data-intro="把当前配置转为XML并提供下载" data-position="left">下载</a></li>
				<li class="dropdown"><a href="#" class="dropdown-toggle"
					data-toggle="dropdown" data-step="5" data-intro="根据元素定位信息来生成数据源、测试套件" data-position="left">生成 <span class="caret"></span></a>
					<ul class="dropdown-menu" role="menu">
						<li><a href="<%=basePath %>/page_info/generateDataSource?id=${pageInfo.id}">数据源</a></li>
						<li><a href="<%=basePath %>/page_info/generateSuiteRunner?id=${pageInfo.id}">测试套件</a></li>
					</ul>
				</li>
				</c:if>
				<li><a href="#" onclick="sysHelp();">帮助</a></li>
			</ul>
		</div>
		<!-- /.navbar-collapse -->
	</div>
	<!-- /.container-fluid -->
</nav>

<div class="container">
    <h1>Page列表</h1>
    <p class="toolbar">
        <a class="create btn btn-default" href="javascript:">新增页面</a>
        <a class="generate btn btn-default" href="javascript:">生成代码</a>
        <span class="alert"></span>
    </p>
    <table id="table"
           data-show-refresh="true"
           data-show-columns="true"
           data-search="true"
           data-query-params="queryParams"
           data-toolbar=".toolbar">
        <thead>
        <tr>
            <th data-checkbox="true">名称</th>
            <th data-field="name">名称</th>
            <th data-field="url">地址</th>
            <th data-field="createTime">创建时间</th>
            <th data-field="remark">备注</th>
            <th data-field="id"
                data-align="center"
                data-formatter="actionFormatter"
                data-events="actionEvents">操作</th>
        </tr>
        </thead>
    </table>
</div>

<div id="modal" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title"></h4>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>页面名称</label>
                    <input type="text" class="form-control" name="name" placeholder="页面名称" required>
                </div>
                <div class="form-group">
                    <label>地址</label>
                    <input type="text" class="form-control" name="url" placeholder="http://surenpi.com" required>
                </div>
                <div class="form-group">
                    <label>备注</label>
                    <input type="text" class="form-control" name="remark" placeholder="备注">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary submit">保存</button>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<script type="text/javascript">
var API_URL = '<%=basePath %>/api/pages_info/${projectId}/';
var $table = $('#table').bootstrapTable({url: API_URL}),
    $modal = $('#modal').modal({show: false}),
    $alert = $('.alert').hide();
    
$(function () {
    $('form').bootstrapValidator();
    
    // create event
    $('.create').click(function () {
        showModal($(this).text());
    });
    $('.generate').click(function(){
    	var ids = getIdSelections();
    	if(ids.length == 0){
    		showAlert('至少要选择一个！', 'danger');
    		return;
    	}
    });
    
    $modal.find('.submit').click(function () {
        var row = {};
        $modal.find('input[name]').each(function () {
            row[$(this).attr('name')] = $(this).val();
        });
        $.ajax({
            url: API_URL + ($modal.data('id') || ''),
            type: $modal.data('id') ? 'put' : 'post',
            contentType: 'application/json',
            data: JSON.stringify(row),
            success: function () {
                $modal.modal('hide');
                $table.bootstrapTable('refresh');
                showAlert(($modal.data('id') ? 'Update' : 'Create') + ' item successful!', 'success');
            },
            error: function () {
                $modal.modal('hide');
                showAlert(($modal.data('id') ? 'Update' : 'Create') + ' item error!', 'danger');
            }
        });
    });
});

function queryParams(params) {
    return {};
}
function actionFormatter(value) {
    return [
        '<a class="update" href="javascript:" title="Update Item"><i class="glyphicon glyphicon-edit"></i></a>',
        '<a class="remove" href="javascript:" title="Delete Item"><i class="glyphicon glyphicon-remove-circle"></i></a>',
        '<a class="list" href="javascript:" title="查看字段"><i class="glyphicon glyphicon-list"></i></a>',
    ].join('');
}
// update and delete events
window.actionEvents = {
    'click .update': function (e, value, row) {
        showModal($(this).attr('title'), row);
    },
    'click .remove': function (e, value, row) {
        if (confirm('Are you sure to delete this item?')) {
            $.ajax({
                url: API_URL + row.id,
                type: 'delete',
                success: function () {
                    $table.bootstrapTable('refresh');
                    showAlert('Delete item successful!', 'success');
                },
                error: function () {
                    showAlert('Delete item error!', 'danger');
                }
            })
        }
    },
    'click .list': function (e, value, row) {
        window.location = '<%=basePath %>/page_info/field/table?pageId=' + row.id;
    }
};
function showModal(title, row) {
    row = row || {
        id: '',
        name: '',
        stargazers_count: 0,
        forks_count: 0,
        description: ''
    }; // default row value
    $modal.data('id', row.id);
    $modal.find('.modal-title').text(title);
    for (var name in row) {
        $modal.find('input[name="' + name + '"]').val(row[name]);
    }
    $modal.modal('show');
}
function showAlert(title, type) {
    $alert.attr('class', 'alert alert-' + type || 'success')
          .html('<i class="glyphicon glyphicon-check"></i> ' + title).show();
    setTimeout(function () {
        $alert.hide();
    }, 3000);
}
function getIdSelections() {
    return $.map($table.bootstrapTable('getSelections'), function (row) {
        return row.id
    });
}
function sysHelp(){
	introJs().setOption('done', 'next').start().oncomplete(function(){
	});
}

$(document).ready(function() {
    $('form').bootstrapValidator();

	$('#engine_tabs li:eq(${pageInfo.tabIndex}) a').tab('show');
	//$('#collapse-搜索框').collapse('toggle')
  });
</script>
</body>
</html>