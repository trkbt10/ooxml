///|
/// XSD complex type CT_Shape (§20.1.16, vml-main.xsd): attributes equationxml; attribute refs o:gfxdata; children o:ink, pvml:iscomment, o:equationxml.
pub(all) struct CT_Shape {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Shape::new(element : @xml.Element) -> CT_Shape {
  { element, }
}

///|
/// XSD complex type CT_Shapetype (§20.1.16, vml-main.xsd): attribute refs o:master; children o:complex.
pub(all) struct CT_Shapetype {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Shapetype::new(element : @xml.Element) -> CT_Shapetype {
  { element, }
}

///|
/// XSD complex type CT_Group (§20.1.16, vml-main.xsd): attributes editas; attribute refs o:tableproperties, o:tablelimits; children group, shape, shapetype, arc, curve, image, line, oval, polyline, rect, roundrect, o:diagram.
pub(all) struct CT_Group {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Group::new(element : @xml.Element) -> CT_Group {
  { element, }
}

///|
/// XSD complex type CT_Background (§20.1.16, vml-main.xsd): attribute refs o:bwmode, o:bwpure, o:bwnormal, o:targetscreensize; children fill.
pub(all) struct CT_Background {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Background::new(element : @xml.Element) -> CT_Background {
  { element, }
}

///|
/// XSD complex type CT_Fill (§20.1.16, vml-main.xsd, vml-officeDrawing.xsd): attributes type, on, color, opacity, color2, src, size, origin, position, aspect, colors, angle, alignshape, focus, focussize, focusposition, method, recolor, rotate; attribute refs o:href, o:althref, o:detectmouseclick, o:title, o:opacity2, r:id, o:relid; children o:fill.
pub(all) struct CT_Fill {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Fill::new(element : @xml.Element) -> CT_Fill {
  { element, }
}

///|
/// XSD complex type CT_Formulas (§20.1.16, vml-main.xsd): children f.
pub(all) struct CT_Formulas {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Formulas::new(element : @xml.Element) -> CT_Formulas {
  { element, }
}

///|
/// XSD complex type CT_F (§20.1.16, vml-main.xsd): attributes eqn.
pub(all) struct CT_F {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_F::new(element : @xml.Element) -> CT_F {
  { element, }
}

///|
/// XSD complex type CT_Handles (§20.1.16, vml-main.xsd): children h.
pub(all) struct CT_Handles {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Handles::new(element : @xml.Element) -> CT_Handles {
  { element, }
}

///|
/// XSD complex type CT_H (§20.1.16, vml-main.xsd): attributes position, polar, map, invx, invy, switch, xrange, yrange, radiusrange.
pub(all) struct CT_H {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_H::new(element : @xml.Element) -> CT_H {
  { element, }
}

///|
/// XSD complex type CT_ImageData (§20.1.16, vml-main.xsd): attributes embosscolor, recolortarget; attribute refs o:href, o:althref, o:title, o:oleid, o:detectmouseclick, o:movie, o:relid, r:id, r:pict, r:href.
pub(all) struct CT_ImageData {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ImageData::new(element : @xml.Element) -> CT_ImageData {
  { element, }
}

///|
/// XSD complex type CT_Path (§20.1.16, vml-main.xsd): attributes v, limo, textboxrect, fillok, strokeok, shadowok, arrowok, gradientshapeok, textpathok, insetpenok; attribute refs o:connecttype, o:connectlocs, o:connectangles, o:extrusionok.
pub(all) struct CT_Path {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Path::new(element : @xml.Element) -> CT_Path {
  { element, }
}

///|
/// XSD complex type CT_Shadow (§20.1.16, vml-main.xsd): attributes on, type, obscured, color, opacity, offset, color2, offset2, origin, matrix.
pub(all) struct CT_Shadow {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Shadow::new(element : @xml.Element) -> CT_Shadow {
  { element, }
}

///|
/// XSD complex type CT_Stroke (§20.1.16, vml-main.xsd): children o:left, o:top, o:right, o:bottom, o:column.
pub(all) struct CT_Stroke {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Stroke::new(element : @xml.Element) -> CT_Stroke {
  { element, }
}

///|
/// XSD complex type CT_Textbox (§20.1.16, vml-main.xsd): attributes inset; attribute refs o:singleclick, o:insetmode; children w:txbxContent.
pub(all) struct CT_Textbox {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Textbox::new(element : @xml.Element) -> CT_Textbox {
  { element, }
}

///|
/// XSD complex type CT_TextPath (§20.1.16, vml-main.xsd): attributes on, fitshape, fitpath, trim, xscale, string.
pub(all) struct CT_TextPath {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_TextPath::new(element : @xml.Element) -> CT_TextPath {
  { element, }
}

///|
/// XSD complex type CT_Arc (§20.1.16, vml-main.xsd): attributes startAngle, endAngle.
pub(all) struct CT_Arc {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Arc::new(element : @xml.Element) -> CT_Arc {
  { element, }
}

///|
/// XSD complex type CT_Curve (§20.1.16, vml-main.xsd): attributes from, control1, control2, to.
pub(all) struct CT_Curve {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Curve::new(element : @xml.Element) -> CT_Curve {
  { element, }
}

///|
/// XSD complex type CT_Image (§20.1.16, vml-main.xsd): empty content model.
pub(all) struct CT_Image {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Image::new(element : @xml.Element) -> CT_Image {
  { element, }
}

///|
/// XSD complex type CT_Line (§20.1.16, vml-main.xsd): attributes from, to.
pub(all) struct CT_Line {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Line::new(element : @xml.Element) -> CT_Line {
  { element, }
}

///|
/// XSD complex type CT_Oval (§20.1.16, vml-main.xsd): empty content model.
pub(all) struct CT_Oval {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Oval::new(element : @xml.Element) -> CT_Oval {
  { element, }
}

///|
/// XSD complex type CT_PolyLine (§20.1.16, vml-main.xsd): attributes points; children o:ink.
pub(all) struct CT_PolyLine {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_PolyLine::new(element : @xml.Element) -> CT_PolyLine {
  { element, }
}

///|
/// XSD complex type CT_Rect (§20.1.16, vml-main.xsd): empty content model.
pub(all) struct CT_Rect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Rect::new(element : @xml.Element) -> CT_Rect {
  { element, }
}

///|
/// XSD complex type CT_RoundRect (§20.1.16, vml-main.xsd): attributes arcsize.
pub(all) struct CT_RoundRect {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RoundRect::new(element : @xml.Element) -> CT_RoundRect {
  { element, }
}

///|
/// XSD complex type CT_ShapeDefaults (§20.1.16, vml-officeDrawing.xsd): attributes spidmax, style, fill, fillcolor, stroke, strokecolor, allowincell; children colormru, colormenu, v:fill, v:stroke, v:textbox, v:shadow, skew, extrusion, callout, lock.
pub(all) struct CT_ShapeDefaults {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeDefaults::new(element : @xml.Element) -> CT_ShapeDefaults {
  { element, }
}

///|
/// XSD complex type CT_Ink (§20.1.16, vml-officeDrawing.xsd): attributes i, annotation, contentType.
pub(all) struct CT_Ink {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Ink::new(element : @xml.Element) -> CT_Ink {
  { element, }
}

///|
/// XSD complex type CT_SignatureLine (§20.1.16, vml-officeDrawing.xsd): attributes issignatureline, id, provid, signinginstructionsset, allowcomments, showsigndate, suggestedsigner, suggestedsigner2, suggestedsigneremail, signinginstructions, addlxml, sigprovurl.
pub(all) struct CT_SignatureLine {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_SignatureLine::new(element : @xml.Element) -> CT_SignatureLine {
  { element, }
}

///|
/// XSD complex type CT_ShapeLayout (§20.1.16, vml-officeDrawing.xsd): children idmap, regrouptable, rules.
pub(all) struct CT_ShapeLayout {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ShapeLayout::new(element : @xml.Element) -> CT_ShapeLayout {
  { element, }
}

///|
/// XSD complex type CT_IdMap (§20.1.16, vml-officeDrawing.xsd): attributes data.
pub(all) struct CT_IdMap {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_IdMap::new(element : @xml.Element) -> CT_IdMap {
  { element, }
}

///|
/// XSD complex type CT_RegroupTable (§20.1.16, vml-officeDrawing.xsd): children entry.
pub(all) struct CT_RegroupTable {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RegroupTable::new(element : @xml.Element) -> CT_RegroupTable {
  { element, }
}

///|
/// XSD complex type CT_Entry (§20.1.16, vml-officeDrawing.xsd): attributes new, old.
pub(all) struct CT_Entry {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Entry::new(element : @xml.Element) -> CT_Entry {
  { element, }
}

///|
/// XSD complex type CT_Rules (§20.1.16, vml-officeDrawing.xsd): children r.
pub(all) struct CT_Rules {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Rules::new(element : @xml.Element) -> CT_Rules {
  { element, }
}

///|
/// XSD complex type CT_R (§20.1.16, vml-officeDrawing.xsd): attributes id, type, how, idref; children proxy.
pub(all) struct CT_R {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_R::new(element : @xml.Element) -> CT_R {
  { element, }
}

///|
/// XSD complex type CT_Proxy (§20.1.16, vml-officeDrawing.xsd): attributes start, end, idref, connectloc.
pub(all) struct CT_Proxy {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Proxy::new(element : @xml.Element) -> CT_Proxy {
  { element, }
}

///|
/// XSD complex type CT_Diagram (§20.1.16, vml-officeDrawing.xsd): attributes dgmstyle, autoformat, reverse, autolayout, dgmscalex, dgmscaley, dgmfontsize, constrainbounds, dgmbasetextscale; children relationtable.
pub(all) struct CT_Diagram {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Diagram::new(element : @xml.Element) -> CT_Diagram {
  { element, }
}

///|
/// XSD complex type CT_EquationXml (§20.1.16, vml-officeDrawing.xsd): attributes contentType.
pub(all) struct CT_EquationXml {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_EquationXml::new(element : @xml.Element) -> CT_EquationXml {
  { element, }
}

///|
/// XSD complex type CT_RelationTable (§20.1.16, vml-officeDrawing.xsd): children rel.
pub(all) struct CT_RelationTable {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_RelationTable::new(element : @xml.Element) -> CT_RelationTable {
  { element, }
}

///|
/// XSD complex type CT_Relation (§20.1.16, vml-officeDrawing.xsd): attributes idsrc, iddest, idcntr.
pub(all) struct CT_Relation {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Relation::new(element : @xml.Element) -> CT_Relation {
  { element, }
}

///|
/// XSD complex type CT_ColorMru (§20.1.16, vml-officeDrawing.xsd): attributes colors.
pub(all) struct CT_ColorMru {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorMru::new(element : @xml.Element) -> CT_ColorMru {
  { element, }
}

///|
/// XSD complex type CT_ColorMenu (§20.1.16, vml-officeDrawing.xsd): attributes strokecolor, fillcolor, shadowcolor, extrusioncolor.
pub(all) struct CT_ColorMenu {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ColorMenu::new(element : @xml.Element) -> CT_ColorMenu {
  { element, }
}

///|
/// XSD complex type CT_Skew (§20.1.16, vml-officeDrawing.xsd): attributes id, on, offset, origin, matrix.
pub(all) struct CT_Skew {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Skew::new(element : @xml.Element) -> CT_Skew {
  { element, }
}

///|
/// XSD complex type CT_Extrusion (§20.1.16, vml-officeDrawing.xsd): attributes on, type, render, viewpointorigin, viewpoint, plane, skewangle, skewamt, foredepth, backdepth, orientation, orientationangle, lockrotationcenter, autorotationcenter, rotationcenter, rotationangle, colormode, color, shininess, specularity, diffusity, metal, edge, facet, lightface, brightness, lightposition, lightlevel, lightharsh, lightposition2, lightlevel2, lightharsh2.
pub(all) struct CT_Extrusion {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Extrusion::new(element : @xml.Element) -> CT_Extrusion {
  { element, }
}

///|
/// XSD complex type CT_Callout (§20.1.16, vml-officeDrawing.xsd): attributes on, type, gap, angle, dropauto, drop, distance, lengthspecified, length, accentbar, textborder, minusx, minusy.
pub(all) struct CT_Callout {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Callout::new(element : @xml.Element) -> CT_Callout {
  { element, }
}

///|
/// XSD complex type CT_Lock (§20.1.16, vml-officeDrawing.xsd): attributes position, selection, grouping, ungrouping, rotation, cropping, verticies, adjusthandles, text, aspectratio, shapetype.
pub(all) struct CT_Lock {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Lock::new(element : @xml.Element) -> CT_Lock {
  { element, }
}

///|
/// XSD complex type CT_OLEObject (§20.1.16, vml-officeDrawing.xsd): attributes Type, ProgID, ShapeID, DrawAspect, ObjectID, UpdateMode; attribute refs r:id; children LinkType, LockedField, FieldCodes.
pub(all) struct CT_OLEObject {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_OLEObject::new(element : @xml.Element) -> CT_OLEObject {
  { element, }
}

///|
/// XSD complex type CT_Complex (§20.1.16, vml-officeDrawing.xsd): empty content model.
pub(all) struct CT_Complex {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_Complex::new(element : @xml.Element) -> CT_Complex {
  { element, }
}

///|
/// XSD complex type CT_StrokeChild (§20.1.16, vml-officeDrawing.xsd): attributes on, weight, color, color2, opacity, linestyle, miterlimit, joinstyle, endcap, dashstyle, insetpen, filltype, src, imageaspect, imagesize, imagealignshape, startarrow, startarrowwidth, startarrowlength, endarrow, endarrowwidth, endarrowlength; attribute refs href, althref, title, forcedash.
pub(all) struct CT_StrokeChild {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_StrokeChild::new(element : @xml.Element) -> CT_StrokeChild {
  { element, }
}

///|
/// XSD complex type CT_ClipPath (§20.1.16, vml-officeDrawing.xsd): attributes v.
pub(all) struct CT_ClipPath {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn CT_ClipPath::new(element : @xml.Element) -> CT_ClipPath {
  { element, }
}

///|
pub fn read_vml_shape(bytes : Bytes) -> CT_Shape raise {
  CT_Shape::new(read_vml_root(bytes, "shape"))
}

///|
pub fn write_vml_shape(value : CT_Shape) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_shapetype(bytes : Bytes) -> CT_Shapetype raise {
  CT_Shapetype::new(read_vml_root(bytes, "shapetype"))
}

///|
pub fn write_vml_shapetype(value : CT_Shapetype) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_group(bytes : Bytes) -> CT_Group raise {
  CT_Group::new(read_vml_root(bytes, "group"))
}

///|
pub fn write_vml_group(value : CT_Group) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_background(bytes : Bytes) -> CT_Background raise {
  CT_Background::new(read_vml_root(bytes, "background"))
}

///|
pub fn write_vml_background(value : CT_Background) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_fill(bytes : Bytes) -> CT_Fill raise {
  CT_Fill::new(read_vml_root(bytes, "fill"))
}

///|
pub fn write_vml_fill(value : CT_Fill) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_stroke(bytes : Bytes) -> CT_Stroke raise {
  CT_Stroke::new(read_vml_root(bytes, "stroke"))
}

///|
pub fn write_vml_stroke(value : CT_Stroke) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_imagedata(bytes : Bytes) -> CT_ImageData raise {
  CT_ImageData::new(read_vml_root(bytes, "imagedata"))
}

///|
pub fn write_vml_imagedata(value : CT_ImageData) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_path(bytes : Bytes) -> CT_Path raise {
  CT_Path::new(read_vml_root(bytes, "path"))
}

///|
pub fn write_vml_path(value : CT_Path) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_textbox(bytes : Bytes) -> CT_Textbox raise {
  CT_Textbox::new(read_vml_root(bytes, "textbox"))
}

///|
pub fn write_vml_textbox(value : CT_Textbox) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_textpath(bytes : Bytes) -> CT_TextPath raise {
  CT_TextPath::new(read_vml_root(bytes, "textpath"))
}

///|
pub fn write_vml_textpath(value : CT_TextPath) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_shapedefaults(bytes : Bytes) -> CT_ShapeDefaults raise {
  CT_ShapeDefaults::new(read_vml_root(bytes, "shapedefaults"))
}

///|
pub fn write_vml_shapedefaults(value : CT_ShapeDefaults) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_ink(bytes : Bytes) -> CT_Ink raise {
  CT_Ink::new(read_vml_root(bytes, "ink"))
}

///|
pub fn write_vml_ink(value : CT_Ink) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_signatureline(bytes : Bytes) -> CT_SignatureLine raise {
  CT_SignatureLine::new(read_vml_root(bytes, "signatureline"))
}

///|
pub fn write_vml_signatureline(value : CT_SignatureLine) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_shapelayout(bytes : Bytes) -> CT_ShapeLayout raise {
  CT_ShapeLayout::new(read_vml_root(bytes, "shapelayout"))
}

///|
pub fn write_vml_shapelayout(value : CT_ShapeLayout) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_idmap(bytes : Bytes) -> CT_IdMap raise {
  CT_IdMap::new(read_vml_root(bytes, "idmap"))
}

///|
pub fn write_vml_idmap(value : CT_IdMap) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_regrouptable(bytes : Bytes) -> CT_RegroupTable raise {
  CT_RegroupTable::new(read_vml_root(bytes, "regrouptable"))
}

///|
pub fn write_vml_regrouptable(value : CT_RegroupTable) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_rules(bytes : Bytes) -> CT_Rules raise {
  CT_Rules::new(read_vml_root(bytes, "rules"))
}

///|
pub fn write_vml_rules(value : CT_Rules) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_diagram(bytes : Bytes) -> CT_Diagram raise {
  CT_Diagram::new(read_vml_root(bytes, "diagram"))
}

///|
pub fn write_vml_diagram(value : CT_Diagram) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_oleobject(bytes : Bytes) -> CT_OLEObject raise {
  CT_OLEObject::new(read_vml_root(bytes, "OLEObject"))
}

///|
pub fn write_vml_oleobject(value : CT_OLEObject) -> Bytes {
  write_element(value.element)
}

///|
pub fn read_vml_complex(bytes : Bytes) -> CT_Complex raise {
  CT_Complex::new(read_vml_root(bytes, "complex"))
}

///|
pub fn write_vml_complex(value : CT_Complex) -> Bytes {
  write_element(value.element)
}
