<?php
/* Smarty version 4.5.5, created on 2026-02-24 21:07:41
  from '/var/www/html/layouts/v7/modules/Install/Step7.tpl' */

/* @var Smarty_Internal_Template $_smarty_tpl */
if ($_smarty_tpl->_decodeProperties($_smarty_tpl, array (
  'version' => '4.5.5',
  'unifunc' => 'content_699e131d827cd3_98285153',
  'has_nocache_code' => false,
  'file_dependency' => 
  array (
    '6b787a041dee8ed6d6a9c82ac25502a5fbd55d1a' => 
    array (
      0 => '/var/www/html/layouts/v7/modules/Install/Step7.tpl',
      1 => 1752039682,
      2 => 'file',
    ),
  ),
  'includes' => 
  array (
  ),
),false)) {
function content_699e131d827cd3_98285153 (Smarty_Internal_Template $_smarty_tpl) {
?>
<center><?php echo call_user_func_array($_smarty_tpl->registered_plugins[ 'modifier' ][ 'vtranslate' ][ 0 ], array( 'LBL_LOADING_PLEASE_WAIT' ));?>
...</center>

<form class="form-horizontal" name="step7" method="post" action="?module=Users&action=Login">
	<img src="//stats.vtiger.com/stats.php?uid=<?php echo $_smarty_tpl->tpl_vars['APPUNIQUEKEY']->value;?>
&v=<?php echo $_smarty_tpl->tpl_vars['CURRENT_VERSION']->value;?>
&type=I&industry=<?php echo call_user_func_array($_smarty_tpl->registered_plugins[ 'modifier' ][ 'urlencode' ][ 0 ], array( $_smarty_tpl->tpl_vars['INDUSTRY']->value ));?>
" alt='' title='' border=0 width='1px' height='1px'>
	<input type=hidden name="username" value="admin" >
	<input type=hidden name="password" value="<?php echo $_smarty_tpl->tpl_vars['PASSWORD']->value;?>
" >
</form>
<?php echo '<script'; ?>
 type="text/javascript">
	jQuery(function () { /* Delay to let page load complete */
		setTimeout(function () {
			jQuery('form[name="step7"]').submit();
		}, 150);
	});
<?php echo '</script'; ?>
>
<?php }
}
