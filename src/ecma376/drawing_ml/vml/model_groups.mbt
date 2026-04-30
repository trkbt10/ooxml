///|
/// XSD attribute group AG_Id (§20.1.16): id.
pub(all) struct AG_Id {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Id::new(element : @xml.Element) -> AG_Id {
  { element, }
}

///|
pub fn AG_Id::attribute_names(self : AG_Id) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_Style (§20.1.16): style.
pub(all) struct AG_Style {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Style::new(element : @xml.Element) -> AG_Style {
  { element, }
}

///|
pub fn AG_Style::attribute_names(self : AG_Style) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_Type (§20.1.16): type.
pub(all) struct AG_Type {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Type::new(element : @xml.Element) -> AG_Type {
  { element, }
}

///|
pub fn AG_Type::attribute_names(self : AG_Type) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_Adj (§20.1.16): adj.
pub(all) struct AG_Adj {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Adj::new(element : @xml.Element) -> AG_Adj {
  { element, }
}

///|
pub fn AG_Adj::attribute_names(self : AG_Adj) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_Path (§20.1.16): path.
pub(all) struct AG_Path {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Path::new(element : @xml.Element) -> AG_Path {
  { element, }
}

///|
pub fn AG_Path::attribute_names(self : AG_Path) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_Fill (§20.1.16): filled, fillcolor.
pub(all) struct AG_Fill {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Fill::new(element : @xml.Element) -> AG_Fill {
  { element, }
}

///|
pub fn AG_Fill::attribute_names(self : AG_Fill) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_Chromakey (§20.1.16): chromakey.
pub(all) struct AG_Chromakey {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Chromakey::new(element : @xml.Element) -> AG_Chromakey {
  { element, }
}

///|
pub fn AG_Chromakey::attribute_names(self : AG_Chromakey) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_Ext (§20.1.16): ext.
pub(all) struct AG_Ext {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_Ext::new(element : @xml.Element) -> AG_Ext {
  { element, }
}

///|
pub fn AG_Ext::attribute_names(self : AG_Ext) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_CoreAttributes (§20.1.16): href, target, class, title, alt, coordsize, coordorigin, wrapcoords, print.
pub(all) struct AG_CoreAttributes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_CoreAttributes::new(element : @xml.Element) -> AG_CoreAttributes {
  { element, }
}

///|
pub fn AG_CoreAttributes::attribute_names(
  self : AG_CoreAttributes,
) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_ShapeAttributes (§20.1.16): opacity, stroked, strokecolor, strokeweight, insetpen.
pub(all) struct AG_ShapeAttributes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_ShapeAttributes::new(element : @xml.Element) -> AG_ShapeAttributes {
  { element, }
}

///|
pub fn AG_ShapeAttributes::attribute_names(
  self : AG_ShapeAttributes,
) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_OfficeCoreAttributes (§20.1.16): o:spid, o:oned, o:regroupid, o:doubleclicknotify, o:button, o:userhidden, o:bullet, o:hr, o:hrstd, o:hrnoshade, o:hrpct, o:hralign, o:allowincell, o:allowoverlap, o:userdrawn, o:bordertopcolor, o:borderleftcolor, o:borderbottomcolor, o:borderrightcolor, o:dgmlayout, o:dgmnodekind, o:dgmlayoutmru, o:insetmode.
pub(all) struct AG_OfficeCoreAttributes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_OfficeCoreAttributes::new(
  element : @xml.Element,
) -> AG_OfficeCoreAttributes {
  { element, }
}

///|
pub fn AG_OfficeCoreAttributes::attribute_names(
  self : AG_OfficeCoreAttributes,
) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_OfficeShapeAttributes (§20.1.16): o:spt, o:connectortype, o:bwmode, o:bwpure, o:bwnormal, o:forcedash, o:oleicon, o:ole, o:preferrelative, o:cliptowrap, o:clip.
pub(all) struct AG_OfficeShapeAttributes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_OfficeShapeAttributes::new(
  element : @xml.Element,
) -> AG_OfficeShapeAttributes {
  { element, }
}

///|
pub fn AG_OfficeShapeAttributes::attribute_names(
  self : AG_OfficeShapeAttributes,
) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_AllCoreAttributes (§20.1.16).
pub(all) struct AG_AllCoreAttributes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_AllCoreAttributes::new(
  element : @xml.Element,
) -> AG_AllCoreAttributes {
  { element, }
}

///|
pub fn AG_AllCoreAttributes::attribute_names(
  self : AG_AllCoreAttributes,
) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_AllShapeAttributes (§20.1.16).
pub(all) struct AG_AllShapeAttributes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_AllShapeAttributes::new(
  element : @xml.Element,
) -> AG_AllShapeAttributes {
  { element, }
}

///|
pub fn AG_AllShapeAttributes::attribute_names(
  self : AG_AllShapeAttributes,
) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_ImageAttributes (§20.1.16): src, cropleft, croptop, cropright, cropbottom, gain, blacklevel, gamma, grayscale, bilevel.
pub(all) struct AG_ImageAttributes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_ImageAttributes::new(element : @xml.Element) -> AG_ImageAttributes {
  { element, }
}

///|
pub fn AG_ImageAttributes::attribute_names(
  self : AG_ImageAttributes,
) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD attribute group AG_StrokeAttributes (§20.1.16): on, weight, color, opacity, linestyle, miterlimit, joinstyle, endcap, dashstyle, filltype, src, imageaspect, imagesize, imagealignshape, color2, startarrow, startarrowwidth, startarrowlength, endarrow, endarrowwidth, endarrowlength, insetpen, o:href, o:althref, o:title, o:forcedash, r:id, o:relid.
pub(all) struct AG_StrokeAttributes {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn AG_StrokeAttributes::new(element : @xml.Element) -> AG_StrokeAttributes {
  { element, }
}

///|
pub fn AG_StrokeAttributes::attribute_names(
  self : AG_StrokeAttributes,
) -> Array[String] {
  let names : Array[String] = []
  for attribute in self.element.attributes {
    names.push(attribute.name.local_name)
  }
  names
}

///|
/// XSD model group EG_ShapeElements (§20.1.16): path, formulas, handles, fill, stroke, shadow, textbox, textpath, imagedata, o:skew, o:extrusion, o:callout, o:lock, o:clippath, o:signatureline, w10:wrap, w10:anchorlock, w10:bordertop, w10:borderbottom, w10:borderleft, w10:borderright, x:ClientData, pvml:textdata.
pub(all) struct EG_ShapeElements {
  element : @xml.Element
} derive(Eq, Debug)

///|
pub fn EG_ShapeElements::new(element : @xml.Element) -> EG_ShapeElements {
  { element, }
}

///|
pub fn EG_ShapeElements::child_names(self : EG_ShapeElements) -> Array[String] {
  let names : Array[String] = []
  for child in self.element.children {
    if child is @xml.Node::Element(child_element) {
      names.push(child_element.name.local_name)
    }
  }
  names
}
