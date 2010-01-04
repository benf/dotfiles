#!/usr/bin/env php
<?php
error_reporting(0);
$dirs = array (
    "/usr/share/applications",
//    "/usr/share/control-center-2.0/capplets",
//    $_SERVER["HOME"] . "/.gnome2/vfolders/applications"
);

function parseDesktopFile($path)
// {{{
{
    $desktop = array ();
    $booleans = array ("false" => false, "true" => true);
    $data = file_get_contents($path);
    $data = str_replace("&", "&amp;", $data);
    $lines = explode("\n", $data);
    foreach ($lines as $l => $line) {
        $line = rtrim($line);
        $pos = strpos($line, "=");
        if (!$pos) continue;
        $field = substr($line, 0, $pos);
        $value = substr($line, ($pos + 1));
        if ($value === false) $value = "";
        if (array_key_exists($value, $booleans)) {
            $value = $booleans[$value];
        }

        $pos = strpos($field, "[");
        if ($pos) {
            $field_name = strtolower(substr($field, 0, $pos));
            $key = substr($field, ($pos + 1), -1);
        } else {
            $field_name = strtolower($field);
        }
        if ($field_name == "categories") {
            if (substr($value, -1) == ";")
                $value = substr($value, 0, -1);
            $value = explode(";", strtolower($value));
        }
        if (!array_key_exists($field_name, $desktop)) {
            $desktop[$field_name] = $value;
        } else if (!is_array($desktop[$field_name])) {
            $default = $desktop[$field_name];
            $desktop[$field_name] = array ("default" => $default);
        } else {
            $desktop[$field_name][$key] = $value;
        }
    }
    if (!array_key_exists("terminal", $desktop))
        $desktop["terminal"] = false;
    return $desktop;
}
// }}}

function storeEntry($name, $exec, $categories, $menu, $indexes = null, $core = false)
// {{{
{
    if (is_null($indexes)) { // first call of this function for this desktop file
        $indexes = array ();
        $indexes["c"] = 0;
        $indexes["nc"] = count($categories);
        $indexes["lc"] = $indexes["nc"] - 1;
    }

    for ($c =& $indexes["c"]; $c < $indexes["nc"]; $c++) { // loop through each category
        $category =& $categories[$c];
        if ($category == "application") {
            $core = true;
            continue;
        }
        $is_last = ($c == $indexes["lc"]);
        if (array_key_exists($category, $menu)) {
            $core = false;
            if ($is_last) { // put entry in current (sub)menu
                $menu[$category][] = array (
                    "appname"   => $name,
                    "appexec"   => $exec
                );
            } else { // look for a matching submenu
                ++$c;
                $menu[$category] = storeEntry($name, $exec, $categories, $menu[$category], $indexes, $core);
            }
            return $menu;
        } else { // unknown category
            if (!$is_last) {
                $core = false;
                continue;
            } else if ($core && $category != "core") { // not a "core" app, not a supported category
                $menu["other"][] = array (
                    "appname"   => $name,
                    "appexec"   => $exec
                );
                return $menu;
            } else { // last category, put it in current (sub)menu
                $menu[] = array (
                    "appname"   => $name,
                    "appexec"   => $exec
                );
                return $menu;
            }
        }
    }
    return $menu;
}
// }}}

function genXML(&$menu, &$labels, $i = 0)
// {{{
{
    static $x = 0;
    $xml = "";
    foreach ($menu as $key => $value) {
        $indentation = str_repeat("  ", $i);
        if (is_string($key)) { // recursion
            list ($label,) = each($labels); // advance pointer no matter what
            if (empty($value)) continue; // menu is empty, there's no point in displaying it
            $xml .= $indentation . "<menu id=\"gnome-menu-$x\" label=\"$label\">\n";
            $xml .= genXML($menu[$key], $labels[$label], $i + 1, ++$x);
            $xml .= $indentation . "</menu>\n";
        } else {
            if (empty($value)) continue;
            $xml .= $indentation . "<item label=\"{$value["appname"]}\"><action name=\"Execute\">"
                    . "<execute>{$value["appexec"]}</execute></action></item>\n";
        }
    }
    return $xml;
}
// }}}

$categories = array (
    "utility"   => array (),
    "settings"  => array (
        "accessibility"     => array (),
        "advancedsettings"  => array ()
    ),
    "education" => array (),
    "game"      => array (),
    "graphics"  => array (),
    "network"   => array (),
    "audiovideo"    => array (
        "audio" => array (),
        "video" => array ()
    ),
    "office"        => array (),
    "other"         => array (),
    "development"   => array (),
    "science"       => array (),
    "system"        => array ()
);

$menu = array (
    "Accessories"   => null,
    "Desktop Preferences"   => array (
        "Accessibility" => null,
        "Advanced"      => null
    ),
    "Education"         => null,
    "Games"             => null,
    "Graphics"          => null,
    "Internet"          => null,
    "Multimedia"        => array (
        "Audio" => null,
        "Video" => null,
    ),
    "Office"            => null,
    "Other"             => null,
    "Programming"       => null,
    "Scientific Tools"  => null,
    "System Tools"      => null
);

$modifiers = array ("%f", "%F", "%u", "%U", "%d", "%D", "%n", "%N", "%i", "%c", "%k", "%v");

$desktops = array ();
$names = array ();
foreach ($dirs as $path) {
    $dir = dir($path);
    while (($entry = $dir->read()) !== false) {
        if (substr($entry, -8) != ".desktop") continue;
        $desktop = parseDesktopFile($path . DIRECTORY_SEPARATOR . $entry);
        if ($desktop === false || !array_key_exists("categories", $desktop)) continue;
        !is_array($desktop["name"]) ? $name = $desktop["name"] : $name = $desktop["name"]["default"];
        $key = & $desktop["exec"];
        $desktops[$key] = $desktop;
        $names[$key] = $name;
    }
}
asort($names);
reset($names);

foreach ($names as $key => $name) {
    $desktop =& $desktops[$key];
    $exec = str_replace($modifiers, "", $desktop["exec"]);
    if ($desktop["terminal"])   $exec = "xterm -e $exec";
    $categories = storeEntry($name, $exec, $desktop["categories"], $categories);
}
?>
<openbox_pipe_menu xmlns="http://openbox.org/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://openbox.org/
    file:///usr/share/openbox/menu.xsd">

<?php echo genXML($categories, $menu, 1); ?>

</openbox_pipe_menu>

