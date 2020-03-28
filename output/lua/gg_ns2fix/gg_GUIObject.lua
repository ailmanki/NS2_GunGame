-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUIObject.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    The base class for all GUI things in the new system.  By default is invisible.
--  
--  Parameters (* = required)
--      align                   Equivalent to calling AlignTop(), AlignCenter(), etc.  Valid values
--                              are:
--                                  topLeft,        top,        topRight,
--                                  left,           center,     right,
--                                  bottomLeft,     bottom,     bottomRight,
--      angle
--      anchor
--      color
--      hotSpot
--      opacity
--      position
--      rotationOffset
--      size
--      scale
--      debugLogProperties      Takes a set (table of [key] = true) of property names that will be
--                              logged and traced every time Set() is called for them.  Useful for
--                              tracking down where bad data is coming from.
--      
--  Properties
--      Anchor                          The location of the origin relative to the parent, in
--                                      normalized coordinates (normalized to parent's scaled
--                                      size).  Default is upper-left corner (0, 0).
--      
--      Angle                           The counter-clockwise rotation, in radians, of this object.
--      
--      BlendTechnique                  How the root GUIItem of this object will be blended when
--                                      rendered.  Choices are:
--                                          GUIItem.Default (unpremultiplied blend)
--                                          GUIItem.Add
--                                          GUIItem.Multiply
--                                          GUIItem.Set (no blending, src overwrites dst)
--                                          GUIItem.Premultiplied
--      
--      ClearsStencilBuffer             True/False, sets whether or not this item clears the
--                                      stencil buffer when it renders.
--      
--      Color                           Sets the color of this GUIItem.  By default, color is
--                                      (0, 0, 0, 0), so this GUIItem is not visible, but its
--                                      children are unaffected by the color.
--      
--      CropMax                         Sets the bottom-right corner of the scissor region for this
--                                      item, in normalized coordinates (normalized to the object's
--                                      size and scale).  By default, items do not use cropping,
--                                      but it is enabled whenever CropMin or CropMax are changed.
--                                      By default it is (0, 0), (which, if cropping were enabled,
--                                      would cause this item to not render).
--                                      When cropping is enabled, children inherit and refine the
--                                      zone (never expand).  If a parent object is completely
--                                      cropped away, none of the children will render either.
--      
--      CropMin                         Sets the top-left corner of the scissor region for this
--                                      item, in normalized coordinates (normalized to the object's
--                                      size and scale).  By default, items do not use cropping,
--                                      but it is enabled whenever CropMin or CropMax are changed.
--                                      By default, it is (0, 0).
--                                      When cropping is enabled, children inherit and refine the
--                                      zone (never expand).  If a parent object is completely
--                                      cropped away, none of the children will render either.
--      
--      DropShadowColor                 Sets the color of the drop shadow effects.  Default is a
--                                      75% opaque black.
--      
--      DropShadowEnabled               Enables/disables the drop shadow effect for text.  Disabled
--                                      by default.  Has no effect on non-text items.
--      
--      DropShadowOffset                Sets the offset of the drop shadow effect, in screen-space
--                                      pixels.  The drop shadow is applied after scaling, so the
--                                      shadow will be at a consistent distance regardless of the
--                                      GUIItem's scale.
--      
--      FontName                        Sets the font file path used to render text with this.
--                                      It is HIGHLY recommended you use GUIText or GUIParagraph to
--                                      display text, rather than the raw GUIItem functionality.
--                                      The aforementioned classes automatically handle font size
--                                      selection and scaling.
--      
--      HotSpot                         The location of the origin of this object, in normalized
--                                      coornates (normalized to this object's scaled size).
--                                      Default is upper-left corner (0, 0).
--      
--      InheritsParentAlpha             True/false.  If true, children's alpha channel (not RGB)
--                                      will be multiplied by the alpha channel of the parent.
--                                      NOTE:  Calling GetColor() WILL reflect this inheritance,
--                                      but values passed to SetColor() will NOT be reflected.
--                                      Example:
--                                          Object A is a parent to object B.
--                                          A:SetColor(1, 1, 1, 0.5)
--                                          B:SetColor(1, 1, 1, 0.8)
--                                          
--                                          B:SetInheritsParentAlpha(false)
--                                          result of B:GetColor() is (1, 1, 1, 0.8)
--                                          
--                                          B:SetInheritsParentAlpha(true)
--                                          result of B:GetColor() is (1, 1, 1, 0.4)
--                                          
--                                          B:SetInheritsParentAlpha(false)
--                                          result of B:GetColor() is (1, 1, 1, 0.8)
--                                          
--                                          B:SetInheritsParentAlpha(true)
--                                          B:SetColor(1, 1, 1, 0.6)
--                                          result of B:GetColor() is (1, 1, 1, 0.3) -- NOT 0.6
--                                      NOTE: This is an engine behavior.  The lua layer (what
--                                      you're currently reading) separates Opacity and Color, but
--                                      combines them when setting the engine (GUIItem) value.  This
--                                      means that the alpha value being inherited is the parent's
--                                      alpha * the parent's opacity.  If the parent GUIObject is
--                                      just a locater object, it will have 0 alpha in the Color
--                                      value, making all children set to inherit alpha invisible.
--                                      In other words... this isn't all that useful here, and is
--                                      only provided for completeness.
--      
--      InheritsParentScaling           True/false.  If true, children will inherit their parent's
--                                      absolute scale before applying their own when calculating
--                                      final transform.  HOWEVER, unlike InheritsParentAlpha, the
--                                      values of Scale are always local.  In other words, this
--                                      property will never cause GetScale() to return a different
--                                      value, as Scale is always local.  To get the absolute scale
--                                      of an object, use the GetAbsoluteScale() method.  Just be
--                                      aware that it is more expensive.
--      
--      InheritsParentStencilSettings   True/false.  If true, children will inherit their parent's
--                                      stencil settings.
--      
--      IsStencil                       True/false.  Whether or not the item will be rendered into
--                                      the stencil buffer.
--      
--      Layer                           Integer describing the relative ordering of this object
--                                      amongst the parent, and amongst its siblings. Default is 0.
--                                      If positive or 0, object will render on top of its parent,
--                                      and will be considered for interactions before the parent.
--                                      If negative, object will render below parent, and will only
--                                      be considered for interactions after the parent.
--      
--      Opacity                         The opacity of the object.  This is applied on top of the
--                                      alpha value of the Color property.
--
--      Position                        The position of the object relative to the parent.  More
--                                      precisely, the offset of the object's hot spot relative to
--                                      the anchor point.
--      
--      RotationOffset                  The normalized offset of the rotation pivot point (the
--                                      point that the object rotates around for the Angle
--                                      property.  Default is upper-left corner (0, 0).
--      
--      Scale                           Local scale of the object.  Default is (1, 1).
--      
--      Shader                          Sets the shader used to render the GUIItem.  Default is
--                                      "shaders/GUIBasic.surface_shader".
--      
--      Size                            Local size of the GUIObject before scaling.
--      
--      SnapsToPixels                   True/false.  Set whether or not to make text snap to
--                                      pixels.  Snapping to pixels preserves some sharpness by
--                                      avoiding the bilinear interpolation, but at the cost of
--                                      smoothness when animating, and less precision for kerning.
--      
--      StencilFunc                     Sets the stencil mode which will change how pixels are
--                                      rendered into the stencil buffer.  Options are:
--                                          GUIItem.Always, -- default
--                                          GUIItem.Equal,
--                                          GUIItem.NotEqual
--      
--      Text                            The text to draw for this item (if text is enabled).  If
--                                      this item is not a text item, this field is unused (but can
--                                      still be used for storage if necessary).
--      
--      Texture                         The filepath of the texture to use for this item.
--      
--      Visible                         True/false if this object is visible.  If false, neither
--                                      this object nor any of its children will be rendered or
--                                      considered for interactions.
--  
--  Events
--      OnDestroy           Fires just before the object is destroyed.  NOTE: When this event
--                          fires, all child objects of this object will have already been
--                          destroyed.
--                              thisObject -- the object being destroyed.
--      
--      OnChildRemoved      Fires when a child object is removed.
--                              removedItem -- the item that was just removed.
--      
--      OnChildAdded        Fires when a child object is added.
--                              addedItem -- the item that was just added.
--                              params -- list of parameters (required by some
--                                  layouts).
--      
--      OnParentChanged     Fires when this object's parent is changed. (Does not detect further-
--                          removed ancestors, only parent.)
--      
--      OnMouseHover        Fires every frame that the mouse is hovering over this object, with no
--                          other objects between this object and the mouse cursor.  Only fires if
--                          this object is setup to receive cursor events (See
--                          GUIObject:ListenForCursorInteractions()).  Note that this does not
--                          always work.  Some widgets will override the basic events without forwarding.
--      
--      OnMouseEnter        Fires when the mouse begins hovering over this object, and no other
--                          objects are between this object and the mouse cursor.  Only fires if
--                          this object is setup to receive cursor events (See
--                          GUIObject:ListenForCursorInteractions()).  Note that this does not
--                          always work.  Some widgets will override the basic events without
--                          forwarding.
--      
--      OnMouseExit         Fires when the mouse, which had been hovering over this object with no
--                          other objects between this object and the mouse cursor -- is no longer
--                          hovering over this object.  Every OnMouseExit event will have had an
--                          earlier matching OnMouseEnter event.  Note that this does not always
--                          work.  Some widgets will override the basic events without forwarding.
--                          Only fires if this object is setup to receive cursor events (See
--                          GUIObject:ListenForCursorInteractions()).
--      
--      OnMouseClick        Fires when the left mouse button is clicked down onto this object.
--                          Only fires if this object is setup to receive cursor events (See
--                          GUIObject:ListenForCursorInteractions()).
--                              double -- this click has followed an earlier rapid click, release.
--                                  Never true if GUIObject:GetCanBeDoubleClicked() returns false,
--                                  (by default never returns true).  When a double click occurs,
--                                  there will be no corresponding mouse up/release/cancel event.
--      
--      OnMouseDrag         Fires every frame that the mouse is clicked down on this object after
--                          OnMouseClick and before the corresponding OnMouseRelease/Cancel/Up.
--                          Fires regardless of whether or not the mouse cursor remains over the
--                          object and regardless of whether or not it is unobstructed.
--                          Only fires if this object is setup to receive cursor events (See
--                          GUIObject:ListenForCursorInteractions()).
--      
--      OnMouseRelease      Fires when the left mouse button is released over this object, but only
--                          after having been clicked down on earlier (firing OnMouseClick).
--                          Only fires if this object is setup to receive cursor events (See
--                          GUIObject:ListenForCursorInteractions()).
--      
--      OnMouseCancel       Fires when the left mouse button is released _not_ over this object,
--                          but only after having been clicked down on earlier (firing
--                          OnMouseClick).
--                          Only fires if this object is setup to receive cursor events (See
--                          GUIObject:ListenForCursorInteractions()).
--      
--      OnMouseUp           Fires when the left mouse button is released after having been clicked
--                          down on earlier, regardless of whether or not it is still over the
--                          object, and _after_ OnMouseRelease or OnMouseCancel is fired.
--                          Only fires if this object is setup to receive cursor events (See
--                          GUIObject:ListenForCursorInteractions()).
--      
--      OnMouseWheel        Fires when the mouse wheel is rolled up or down with the cursor over
--                          this object.  Only fires if this object is setup to receive wheel
--                          events (See GUIObject:ListenForWheelInteractions()).
--                              up -- true/false the wheel movement was up (otherwise down).
--      
--      OnKey               Fires when a keyboard key is pressed down or released, and is the top-
--                          most visible listener.  Only fires if this object is setup to receive
--                          keyboard events (See GUIObject:ListenForKeyInteractions()).
--                              key -- a value from the InputKey set.
--                              down -- true/false if this event is for a key being pressed down.
--                              Otherwise up.
--      
--      OnCharacter         Fires when a character is typed in by the user.  This will only occur
--                          when the object is listening for characters (See
--                          GUIObject:ListenForCharacters()).
--                              character -- the character that is received, as a UTF-8 string (eg
--                                  #character might be > 1).
--      
--      OnOutsideClick      Called when the object is modal and the mouse is clicked down outside
--                          the object. (See GUIObject:SetModal()).
--      
--      OnOutsideWheel      Called when the object is modal and the mouse wheel is rolled when the
--                          cursor is outside the object.  (See GUIObject:SetModal()).
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/LayerConstants.lua")
DefineLayerConstants()

Script.Load("lua/GUI/GUIUtils.lua")

-- Load the GUIManagers.  The order they are loaded in IS important.
-- Load GUIAnimationManager first.  Animations (setup from previous frame), should update first.
Script.Load("lua/GUI/GUIAnimationManager.lua")

-- Load GUIUpdateManager next.  This is for objects that are updated every frame.
Script.Load("lua/GUI/GUIUpdateManager.lua")

-- Load GUIRenderedStatusManager next.  This allows objects to be told when they've started being
-- rendered, and when they've stopped being rendered.
Script.Load("lua/GUI/GUIRenderedStatusManager.lua")

-- Load GUIEventManager next.  This manages the event message passing system.
Script.Load("lua/GUI/GUIEventManager.lua")

-- Load GUIInteractionManager next.  This is what brings user input into the system.
Script.Load("lua/GUI/GUIInteractionManager.lua")

-- Load GUITimedCallbackManager next.
Script.Load("lua/GUI/GUITimedCallbackManager.lua")

-- Load GUIDeferredUniqueEventManager last so that it is the last manager to update in each frame.
Script.Load("lua/GUI/GUIDeferredUniqueCallbackManager.lua")

-- Load all the debug functionality.  Leave it in even for release (not much overhead in it, and may
-- come in handy to diagnose bugs in the wild).
Script.Load("lua/GUI/GUIDebug.lua")

-- Use values inside GUIItem as "fake" properties.  We've purposefully excluded "Color" from this.
-- See actual definition of Color and Opacity for an explanation.
g_GUIItemFakeProperties =
{
    Anchor                        = { type = "Vector",  getter = GUIItem.GetAnchor,                        setter = GUIItem.SetAnchor,                        },
    Angle                         = { type = "number",  getter = GUIItem.GetAngle,                         setter = GUIItem.SetAngle,                         },
    BlendTechnique                = { type = "number",  getter = GUIItem.GetBlendTechnique,                setter = GUIItem.SetBlendTechnique,                },
    ClearsStencilBuffer           = { type = "boolean", getter = GUIItem.GetClearsStencilBuffer,           setter = GUIItem.SetClearsStencilBuffer,           },
    CropMax                       = { type = "Vector",  getter = GUIItem.GetCropMaxCornerNormalized,       setter = GUIItem.SetCropMaxCornerNormalized,       },
    CropMin                       = { type = "Vector",  getter = GUIItem.GetCropMinCornerNormalized,       setter = GUIItem.SetCropMinCornerNormalized,       },
    DropShadowColor               = { type = "Color",   getter = GUIItem.GetDropShadowColor,               setter = GUIItem.SetDropShadowColor,               },
    DropShadowEnabled             = { type = "boolean", getter = GUIItem.GetDropShadowEnabled,             setter = GUIItem.SetDropShadowEnabled,             },
    DropShadowOffset              = { type = "Vector",  getter = GUIItem.GetDropShadowOffset,              setter = GUIItem.SetDropShadowOffset,              },
    FontName                      = { type = "string",  getter = GUIItem.GetFontName,                      setter = GUIItem.SetFontName,                      },
    HotSpot                       = { type = "Vector",  getter = GUIItem.GetHotSpot,                       setter = GUIItem.SetHotSpot,                       },
    InheritsParentAlpha           = { type = "boolean", getter = GUIItem.GetInheritsParentAlpha,           setter = GUIItem.SetInheritsParentAlpha,           },
    InheritsParentScaling         = { type = "boolean", getter = GUIItem.GetInheritsParentScaling,         setter = GUIItem.SetInheritsParentScaling,         },
    InheritsParentStencilSettings = { type = "boolean", getter = GUIItem.GetInheritsParentStencilSettings, setter = GUIItem.SetInheritsParentStencilSettings, },
    InheritsParentPosition        = { type = "boolean", getter = GUIItem.GetInheritsParentPosition,        setter = GUIItem.SetInheritsParentPosition,        },
    IsStencil                     = { type = "boolean", getter = GUIItem.GetIsStencil,                     setter = GUIItem.SetIsStencil,                     },
    Layer                         = { type = "number",  getter = GUIItem.GetLayer,                         setter = GUIItem.SetLayer,                         },
    Position                      = { type = "Vector",  getter = GUIItem.GetPosition,                      setter = GUIItem.SetPosition,                      },
    RotationOffset                = { type = "Vector",  getter = GUIItem.GetRotationOffsetNormalized,      setter = GUIItem.SetRotationOffsetNormalized,      },
    Scale                         = { type = "Vector",  getter = GUIItem.GetScale,                         setter = GUIItem.SetScale,                         },
    Shader                        = { type = "string",  getter = GUIItem.GetShader,                        setter = GUIItem.SetShader,                        },
    Size                          = { type = "Vector",  getter = GUIItem.GetSize,                          setter = GUIItem.SetSize,                          },
    SnapsToPixels                 = { type = "boolean", getter = GUIItem.GetSnapsToPixels,                 setter = GUIItem.SetSnapsToPixels,                 },
    StencilFunc                   = { type = "number",  getter = GUIItem.GetStencilFunc,                   setter = GUIItem.SetStencilFunc,                   },
    Text                          = { type = "string",  getter = GUIItem.GetText,                          setter = GUIItem.SetText,                          },
    Texture                       = { type = "string",  getter = GUIItem.GetTexture,                       setter = GUIItem.SetTexture,                       },
    Visible                       = { type = "boolean", getter = GUIItem.GetIsVisible,                     setter = GUIItem.SetIsVisible,                     },
}

function GetIsaFakeProperty(propertyName)
    return propertyName ~= nil and g_GUIItemFakeProperties[propertyName] ~= nil
end

---@class GUIObject
---@field public GetAnchor function
---@field public SetAnchor function
---@field public GetAngle function
---@field public SetAngle function
---@field public GetBlendTechnique function
---@field public SetBlendTechnique function
---@field public GetClearsStencilBuffer function
---@field public SetClearsStencilBuffer function
---@field public GetColor function
---@field public SetColor function
---@field public GetCropMax function
---@field public SetCropMax function
---@field public GetCropMin function
---@field public SetCropMin function
---@field public GetDropShadowColor function
---@field public SetDropShadowColor function
---@field public GetDropShadowEnabled function
---@field public SetDropShadowEnabled function
---@field public GetDropShadowOffset function
---@field public SetDropShadowOffset function
---@field public GetFontName function
---@field public SetFontName function
---@field public GetHotSpot function
---@field public SetHotSpot function
---@field public GetInheritsParentAlpha function
---@field public SetInheritsParentAlpha function
---@field public GetInheritsParentScaling function
---@field public SetInheritsParentScaling function
---@field public GetInheritsParentStencilSettings function
---@field public SetInheritsParentStencilSettings function
---@field public GetIsStencil function
---@field public SetIsStencil function
---@field public GetLayer function
---@field public SetLayer function
---@field public GetOpacity function
---@field public SetOpacity function
---@field public GetPosition function
---@field public SetPosition function
---@field public GetRotationOffset function
---@field public SetRotationOffset function
---@field public GetScale function
---@field public SetScale function
---@field public GetShader function
---@field public SetShader function
---@field public GetSize function
---@field public SetSize function
---@field public GetSnapsToPixels function
---@field public SetSnapsToPixels function
---@field public GetStencilFunc function
---@field public SetStencilFunc function
---@field public GetText function
---@field public SetText function
---@field public GetTexture function
---@field public SetTexture function
---@field public GetVisible function
---@field public SetVisible function
---@field public ClearCropRectangle function
---@field public ForceUpdateTextSize function
---@field public GetTextureHeight function
---@field public GetTextureWidth function
---@field public SetFloatParameter function
---@field public SetFloat2Parameter function
---@field public SetFloat3Parameter function
---@field public SetFloat4Parameter function
---@field public GetAbsoluteScale function
---@field public GetWasRenderedLastFrame function
---@field public CalculateTextSize function
---@field public SetTexturePixelCoordinates
---@field public SetTextureCoordinates
---@field public AlignTopLeft function
---@field public AlignTop function
---@field public AlignTopRight function
---@field public AlignLeft function
---@field public AlignCenter function
---@field public AlignRight function
---@field public AlignBottomLeft function
---@field public AlignBottom function
---@field public AlignBottomRight function
class "GUIObject"


-- Special value to symbolize no object.  A special value is necessary because properties cannot
-- carry a nil value.
GUIObject.NoObject = {}

-- Mapping of GUIItem -> GUIObject.  Every GUIItem should belong to exactly one GUIObject.
local guiItemToGUIObjectMapping = {}

-- Keep track of which classes have had their Initialize methods called.
local classInstantiated = {}

-- Used for retrieving list of items from engine.
local guiItemArray = GUIItemArray()

-- Used for ensuring that the number of Initialize calls is correct (to catch when we forget or skip
-- over calling classes' Initialize methods).  Traversing class hierarchy can be slow, so we cache
-- the results here.
local classInitDepthCache = {[GUIObject] = 1}


----------------------------------------------------------------------------------------------------
---------------------------------------------- LOCALS ----------------------------------------------
----------------------------------------------------------------------------------------------------


local function GetClassPropertyFieldName(propertyName)
    return "_classProp_"..propertyName
end

local function GetClassPropertyNoCopyFieldName(propertyName)
    return "_classProp_"..propertyName.."_noCopy"
end

local function GetInstancePropertyFieldName(propertyName)
    return "_prop_"..propertyName
end
GUIObject._GetInstancePropertyFieldName = GetInstancePropertyFieldName

local function GetInstancePropertyNoCopyFieldName(propertyName)
    return "_prop_"..propertyName.."_noCopy"
end

local function GetCompositeClassPropertyFieldName(propertyName)
    return "_compositeClassProp_"..propertyName
end

local function GetCompositeClassPropertyOtherName(propertyName)
    return "_compositeClassProp_"..propertyName.."_altName"
end

local function GetGetterNameForProperty(propertyName)
    return "Get"..propertyName
end
GUIObject._GetGetterNameForProperty = GetGetterNameForProperty

local function GetSetterNameForProperty(propertyName)
    return "Set"..propertyName
end
GUIObject._GetSetterNameForProperty = GetSetterNameForProperty

local function GetRawSetterNameForProperty(propertyName)
    return "RawSet"..propertyName
end
GUIObject._GetRawSetterNameForProperty = GetRawSetterNameForProperty

local function GetChangedEventNameForProperty(propertyName)
    return "On"..propertyName.."Changed"
end
GUIObject._GetChangedEventNameForProperty = GetChangedEventNameForProperty

local function GetAnimatedPropertyBaseValue(self, propertyName)
    local result = GetGUIAnimationManager():GetAnimatingPropertyBaseValue(self, propertyName)
    return result
end

local function InstancePropertyGetter(self, propertyName)
    
    local instancePropertyFieldName = GetInstancePropertyFieldName(propertyName)
    local result = self[instancePropertyFieldName]
    assert(result ~= nil)
    return result
    
end

local function FakePropertyGetter(self, propertyName)
    
    local itemGetter = GetGUIItemPropertyGetter(propertyName)
    assert(itemGetter)
    local result = itemGetter(self:GetRootItem())
    assert(result ~= nil)
    return result

end

-- Attempts to set the value of an animating property.  Returns false if the property was not
-- animating.
local function SetForAnimatingProperty(self, propertyName, value, prevValue)
    local result = GetGUIAnimationManager():SetAnimatingPropertyBaseValue(self, propertyName, value)
    return result
end

-- Sets the value of a non-fake property.
local function InstancePropertySetter(self, propertyName, value)
    
    local instancePropertyFieldName = GetInstancePropertyFieldName(propertyName)
    local noCopyFieldName = GetInstancePropertyNoCopyFieldName(propertyName)
    local noCopy = noCopyFieldName ~= nil and self[noCopyFieldName] == true
    if noCopy then
        self[instancePropertyFieldName] = value
    else
        self[instancePropertyFieldName] = Copy(value)
    end
    
end
GUIObject._InstancePropertySetter = InstancePropertySetter

local fakePropertySetters = {}
local function GetFakePropertySetter(itemName)
    
    itemName = itemName or "rootItem"
    local key = itemName.."_property_setter"
    
    local setter = fakePropertySetters[key]
    if not setter then
        setter = function(self, propertyName, value)
            
            local itemSetter = GetGUIItemPropertySetter(propertyName)
            assert(itemSetter)
            assert(itemName ~= nil)
            
            local item = self[itemName]
            if not item then
                error(string.format("Unable to find member item named '%s'!", itemName), 2)
            end
    
            itemSetter(self[itemName], value)
            
        end
        fakePropertySetters[key] = setter
    end
    
    return setter
    
end

local function FirePropertyChangeEvent(self, propertyName, value, prevValue)
    
    -- Only call self:FireEvent() if we don't already have one queued up.  If we DO have one
    -- already queued up, update its "after" value to reflect the changes here (and leave prevValue
    -- untouched, since the prevValue this function was called with won't ever be reacted to since
    -- we're switching off it).
    
    if not self.callbacks then
        return -- nothing is listening to this object.
    end
    
    -- Unfortunately this means rolling our own new fire event function...
    local eventName = GetChangedEventNameForProperty(propertyName)
    
    for i=1, #self.callbacks do
        local callback = self.callbacks[i]
        
        if callback.eventName == eventName then
            
            -- Fire/update this event.  Check to see if we have one already in the pipe.
            local usingPrevValue = prevValue
            local callbackRef -- found callback ref
            local callbackRefs = GetGUIEventManager():GetCallbackRefs(callback)
            
            -- Should only ever have at-most one of these callbacks in the pipe at a time... but
            -- its possible a user is sending their own.  Just pick the first valid one in this
            -- case.
            if callbackRefs then
                assert(not callbackRefs[1].removed)
                callbackRef = callbackRefs[1]
            end
            
            if callbackRef then
                usingPrevValue = callbackRef[3] -- third slot is second parameter, which is prevValue.
                
                -- Remove all the callback refs, in order to make it unique.
                GetGUIEventManager():OnCallbackRemoved(callback)
            end
            
            -- If a value is set, and then immediately changed back before the event can fire, (eg
            -- prevValue and value are the same), the event should not fire, since no change has
            -- officially taken place.
            local same = GetAreValuesTheSame(usingPrevValue, value)
            
            if not same then
                GetGUIEventManager():EnqueueEventCallback(callback, value, usingPrevValue)
            end
            
        end
    end
    
    if not self.eventsPaused then
        GetGUIEventManager():ProcessEventQueue()
    end
    
end

-- Sets the property to the value, which may involve updating the animated base value rather than a
-- direct assignment.  Also handles firing an On_____Changed event if the value is different from
-- before.  "setter" is a function used to set the property if it is not animated.  This will be
-- either "InstancePropertySetter", or "FakePropertySetter"
local function PerformSetterDuties(self, propertyName, value, setter, altPropertyName, noEvent)
    
    if value == nil then
        return true
    end
    
    assert(value ~= nil)
    
    local prevValue = self:Get(propertyName)
    
    -- Update property base value in animation manager, if it is animating.  This function also
    -- provides a check for if the value was changed, so this event will only fire when the base
    -- value changes.
    if SetForAnimatingProperty(self, propertyName, value, prevValue) then
        
        if not noEvent then
            FirePropertyChangeEvent(self, propertyName, value, prevValue)
        end
        
        return true
    end
    
    -- Don't change any values or fire any events if the value was unchanged.
    local same = GetAreValuesTheSame(prevValue, value)
    if same then
        return false
    end
    
    -- If this property name is being traced, log this change.
    if self.debugLogProperties and self.debugLogProperties[propertyName] then
        Log("Property '%s' of '%s' about to change from '%s' to '%s'... trace:\n%s", propertyName, self:GetName(), prevValue, value, Debug_GetStackTraceForEvent(true))
    end
    
    setter(self, altPropertyName, value)
    if not noEvent then
        FirePropertyChangeEvent(self, propertyName, value, prevValue)
    end
    
    return true
    
end
GUIObject._PerformSetterDuties = PerformSetterDuties -- occasionally another object will need to use this.

local function PerformGetterDuties(self, propertyName, static, getter)
    
    -- If the non-animated value is requested, check and see if this value is animating.  If so,
    -- return the base value.
    if static == true then
        local result = GetAnimatedPropertyBaseValue(self, propertyName)
        if result ~= nil then
            return result
        end
    end
    
    -- Not animated, or didn't request non-animated value.  Get the value.
    local value = getter(self, propertyName)
    assert(value ~= nil)
    
    return value
    
end
GUIObject._PerformGetterDuties = PerformGetterDuties -- occasionally another object will need to use this.

local ProcessVectorInput = ProcessVectorInput -- from GUIItemExtras.lua
local ProcessColorInput = ProcessColorInput -- from GUIItemExtras.lua

local function AutomaticallyDefineSetterAndGetter(owner, propertyName, propertyType)
    
    -- Getter
    local getterName = GetGetterNameForProperty(propertyName)
    if not owner[getterName] then
        owner[getterName] = GUIObject.GetAutoGeneratedGetter(propertyName)
    end
    
    -- Setter
    local setterName = GetSetterNameForProperty(propertyName)
    if not owner[setterName] then
        owner[setterName] = GUIObject.GetAutoGeneratedSetter(propertyName, propertyType)
    end
    
    -- Raw Setter
    local rawSetterName = GetRawSetterNameForProperty(propertyName)
    if not owner[rawSetterName] then
        owner[rawSetterName] = GUIObject.GetAutoGeneratedRawSetter(propertyName, propertyType)
    end
    
end

local function DoPropertyAlreadyExistsError(propertyName, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    error(string.format("Property named '%s' already exists!", propertyName), errorDepth)
end

local function GetPropertyExistsForClass(cls, propertyName, prohibitCompositeRefs, errorDepth)
    errorDepth = (errorDepth or 1) + 1

    RequireClassIsa("GUIObject", cls, "cls", errorDepth)

    -- Check GUIItem properties.
    if GetIsaFakeProperty(propertyName) then
        return true
    end

    -- Check class properties.
    if cls[GetClassPropertyFieldName(propertyName)] ~= nil then
        return true
    end

    -- Check composite class properties.
    if not prohibitCompositeRefs and cls[GetCompositeClassPropertyFieldName(propertyName)] ~= nil then
        return true
    end

    return false

end

local function GetPropertyExistsForGUIObject(self, propertyName, prohibitCompositeRefs, errorDepth)
    errorDepth = (errorDepth or 1) + 1

    AssertIsaGUIObject(self, errorDepth)
    AssertIsNotDestroyed(self, errorDepth)

    -- Check GUIItem properties
    if GetIsaFakeProperty(propertyName) then
        return true
    end

    -- Check for instance properties with the same name.  Class properties will have been added to
    -- the instance's state by now, so we don't need to explicitly check for class properties.
    if self[GetInstancePropertyFieldName(propertyName)] ~= nil then
        return true
    end

    -- Check for composite property references.
    if not prohibitCompositeRefs and self[GetCompositeClassPropertyFieldName(propertyName)] ~= nil then
        return true
    end

    return false

end

local function ValidatePropertyCreation(propertyName, instance, cls, defaultValue, errorDepth)
    errorDepth = (errorDepth or 1) + 1

    ValidatePropertyName(propertyName, 1, errorDepth)
    
    -- Ensure property does not already exist.
    if instance == nil then
        assert(cls ~= nil)
        if GetPropertyExistsForClass(cls, propertyName, false, errorDepth) then
            DoPropertyAlreadyExistsError(propertyName, errorDepth)
        end
    else
        assert(cls == nil)
        if GetPropertyExistsForGUIObject(instance, propertyName, false, errorDepth) then
            DoPropertyAlreadyExistsError(propertyName, errorDepth)
        end
    end
    
    -- Ensure property name will not create conflicts with existing method names.
    -- Check Getter name.
    local instanceOrClass = instance or cls
    local getterName = GetGetterNameForProperty(propertyName)
    if instanceOrClass[getterName] ~= nil then
        error(string.format("Cannot create property named '%s': Property getter name '%s' is already defined for this class.", propertyName, getterName), errorDepth)
    end
    
    local setterName = GetSetterNameForProperty(propertyName)
    if instanceOrClass[setterName] ~= nil then
        error(string.format("Cannot create property named '%s': Property setter name '%s' is already defined for this class.", propertyName, setterName), errorDepth)
    end
    
    local rawSetterName = GetRawSetterNameForProperty(propertyName)
    if instanceOrClass[rawSetterName] ~= nil then
        error(string.format("Cannot create property named '%s': Property raw setter name '%s' is already defined for this class.", propertyName, rawSetterName), errorDepth)
    end
    
    -- Default value cannot be nil.
    if defaultValue == nil then
        error(string.format("No default value provided when adding property '%s'!", propertyName), errorDepth)
    end
    
end

-- Search through the given GUIItemArray for a GUIItem that maps to a GUIObject with the given name.
-- Optionally, continue searching even after we've found one to see if it is a unique object.
local function FindObjectWithNameInGUIItemArray(array, name, checkForUnique)
    
    local found = nil
    for i=0, array:GetSize() - 1 do
        local item = array:Get(i)
        local object = GetOwningGUIObject(item)
        if object and object.name == name then
            
            if checkForUnique then
                if found ~= nil then
                    return object, false
                end
            else
                return object
            end
            
            found = object
            
        end
    end
    
    if checkForUnique then
        return found, true
    else
        return found
    end
    
end

local doneIsaOverrides = { [GUIObject] = true }
local function OverrideIsaForClass(cls)
    
    assert(type(cls) == "table")
    
    if doneIsaOverrides[cls] then
        return
    end
    
    -- Get the base class of this class.
    local baseClass = GetBaseClass(cls)
    assert(baseClass)
    
    -- Ensure base class has had its isa override completed.
    OverrideIsaForClass(baseClass)
    
    -- Create a new isa method just for this class.
    local thisClassName = cls.classname
    cls.isa = function(self, className)
        return className == thisClassName or baseClass:isa(className)
    end
    
    -- Mark this class as having done the isa override, so we don't duplicate work.
    doneIsaOverrides[cls] = true
    
end

-- Calculates the number of Initialize calls expected between GUIObject and the top level class
-- given.  Calculated by traversing path to GUIObject, incrementing count by 1 each time a unique
-- Initialize field is encountered.
local function GetExpectedClassInitializeDepth(cls)
    
    local cachedValue = classInitDepthCache[cls]
    if cachedValue then
        return cachedValue
    end
    
    local baseClass = GetBaseClass(cls)
    
    if not baseClass then
        error(string.format("Expected a GUIObject-based class, got %s instead", cls), 2)
    end
    
    local depth = GetExpectedClassInitializeDepth(baseClass)
    
    if cls.Initialize ~= baseClass.Initialize then
        depth = depth + 1
    end
    
    classInitDepthCache[cls] = depth
    
    return depth
    
end


----------------------------------------------------------------------------------------------------
------------------------------------ GENERAL GUIOBJECT METHODS -------------------------------------
----------------------------------------------------------------------------------------------------

-- Create helper methods that use existing "fake property" methods.  Don't define them like above,
-- as this would skip any events hooked into them.
GUIObject.AlignTopLeft     = function(self) self:SetAnchor(0.0, 0.0) self:SetHotSpot(0.0, 0.0) end
GUIObject.AlignTop         = function(self) self:SetAnchor(0.5, 0.0) self:SetHotSpot(0.5, 0.0) end
GUIObject.AlignTopRight    = function(self) self:SetAnchor(1.0, 0.0) self:SetHotSpot(1.0, 0.0) end
GUIObject.AlignLeft        = function(self) self:SetAnchor(0.0, 0.5) self:SetHotSpot(0.0, 0.5) end
GUIObject.AlignCenter      = function(self) self:SetAnchor(0.5, 0.5) self:SetHotSpot(0.5, 0.5) end
GUIObject.AlignRight       = function(self) self:SetAnchor(1.0, 0.5) self:SetHotSpot(1.0, 0.5) end
GUIObject.AlignBottomLeft  = function(self) self:SetAnchor(0.0, 1.0) self:SetHotSpot(0.0, 1.0) end
GUIObject.AlignBottom      = function(self) self:SetAnchor(0.5, 1.0) self:SetHotSpot(0.5, 1.0) end
GUIObject.AlignBottomRight = function(self) self:SetAnchor(1.0, 1.0) self:SetHotSpot(1.0, 1.0) end

local kAlignParamValues =
{
    topLeft     = "AlignTopLeft",
    top         = "AlignTop",
    topRight    = "AlignTopRight",
    left        = "AlignLeft",
    center      = "AlignCenter",
    right       = "AlignRight",
    bottomLeft  = "AlignBottomLeft",
    bottom      = "AlignBottom",
    bottomRight = "AlignBottomRight",
}

-- Called when the GUIObject is first created.  Like a constructor.
-- NOTE:  At this stage, the object does not yet have a parent.
function GUIObject:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    -- Optimize "isa()" calls by providing our own method.
    OverrideIsaForClass(_G[self.classname])
    
    -- Can be provided with a set of property names that will have all Set() calls to them logged
    -- and traced.
    RequireType({"table", "nil"}, params.debugLogProperties, "params.debugLogProperties", errorDepth)
    if params.debugLogProperties then
        if #params.debugLogProperties > 0 then
            error("params.debugLogProperties length not zero!  Did you make a list of property names instead of a set?  (should be mapping of propertyName --> true).", errorDepth)
        end
        self.debugLogProperties = params.debugLogProperties
    end
    
    RequireType({"Color", "nil"}, params.color, "params.color", errorDepth)
    RequireType({"number", "nil"}, params.opacity, "params.opacity", errorDepth)
    RequireType({"string", "nil"}, params.align, "params.align", errorDepth)
    if params.align and not kAlignParamValues[params.align] then
        error(string.format("Invalid align value!  Valid values are: topLeft, top, topRight, left, center, right, bottomLeft, bottom, bottomRight.  Got '%s'.", params.align), errorDepth)
    end
    RequireType({"Vector", "nil"}, params.position, "params.position", errorDepth)
    RequireType({"number", "nil"}, params.angle, "params.angle", errorDepth)
    RequireType({"Vector", "nil"}, params.rotationOffset, "params.rotationOffset", errorDepth)
    RequireType({"Vector", "nil"}, params.anchor, "params.anchor", errorDepth)
    RequireType({"Vector", "nil"}, params.hotSpot, "params.hotSpot", errorDepth)
    RequireType({"Vector", "nil"}, params.size, "params.size", errorDepth)
    RequireType({"Vector", "nil"}, params.scale, "params.scale", errorDepth)
    
    -- Certain functions can only be used before a class has been instantiated.
    local cls = _G[self.classname]
    assert(cls)
    if not classInstantiated[cls] then
        classInstantiated[cls] = true
    end
    
    -- Create class property instantiations for this object.
    if cls._classPropList then
        for i=1, #cls._classPropList do
            local propertyName = cls._classPropList[i]
            local noCopy = cls[GetClassPropertyNoCopyFieldName(propertyName)]
            assert(noCopy ~= nil)
            local defaultValue = cls[GetClassPropertyFieldName(propertyName)]
            assert(defaultValue ~= nil)
            local instancePropertyFieldName = GetInstancePropertyFieldName(propertyName)
            
            if noCopy then
                -- Reference the default value in the instance property, and make note that this
                -- property is a "no copy" property.
                
                self[instancePropertyFieldName] = defaultValue
                self[GetInstancePropertyNoCopyFieldName(propertyName)] = true
            else
                -- Copy the default value to the instance property.
                self[instancePropertyFieldName] = Copy(defaultValue)
            end
        end
    end
    
    -- Every GUIObject has a GUIItem "rootItem" -- the GUIObject's representation in the engine.
    self.rootItem = self:CreateLocatorGUIItem()
    assert(self.rootItem)
    
    -- Safety check, since this is a common mistake.
    self._guiObjectInitCalled = true
    
    -- Safety check, ensure that we're at the expected depth.  If we're not, this is a sign that we
    -- may have skipped some Initialize calls of some derived classes (common mistake is to forget
    -- to call wrapper Initialize methods).
    local expectedDepth = GetExpectedClassInitializeDepth(_G[self.classname])
    local startDepth = GetErrorDepthAtInitGUIObjectCall()
    local actualDepth = errorDepth - startDepth
    
    if expectedDepth ~= actualDepth then
        error(string.format("Number of Initialize calls between %s:Initialize() and GUIObject:Initialize() didn't match expected value!  This can be caused by: 1) Not incrementing errorDepth by 1 for each Initialize call, or 2) Not calling Initialize of some intermediate class (eg wrappers).", self.classname), errorDepth)
    end
    
    if params.color then
        self:SetColor(params.color)
    end
    
    if params.opacity then
        self:SetOpacity(params.opacity)
    end
    
    if params.hotSpot then
        self:SetHotSpot(params.hotSpot)
    end
    
    if params.anchor then
        self:SetAnchor(params.anchor)
    end
    
    if params.align then
        local methodName = kAlignParamValues[params.align]
        local method = self[methodName]
        assert(method)
        method(self)
    end
    
    if params.position then
        self:SetPosition(params.position)
    end
    
    if params.angle then
        self:SetAngle(params.angle)
    end
    
    if params.rotationOffset then
        self:SetRotationOffset(params.rotationOffset)
    end
    
    if params.size then
        self:SetSize(params.size)
    end
    
    if params.scale then
        self:SetScale(params.scale)
    end
    
end

-- Sets up the composite class property "On_____Changed" event forwarding, if necessary.
-- Returns true if:
--      Event was forwarded successfully.
--      or event had already been forwarded.
--      or event could not be created because the member object is a GUIItem (and thus will never send
--          events).
-- Returns false if:
--      Event didn't exist, and was not created due to not finding the member object required.
-- raises an error if member object is non-nil and the wrong type.
local function ForwardEventForCompositeClassPropertyChangeEvent(self, propertyNameThisObject, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    -- Should be completed with initialization, not after.
    assert(self:GetIsInitializing())
    
    local memberObjectName = self[GetCompositeClassPropertyFieldName(propertyNameThisObject)]
    assert(memberObjectName)
    
    local memberThing = self[memberObjectName]
    if memberThing == nil then
        return false -- member object doesn't exist yet.
    end
    
    -- GUIItems cannot fire events.
    if memberThing:isa("GUIItem") then
        return true
    end
    
    if not memberThing:isa("GUIObject") then
        error(string.format("Class '%s' declared a composite property referencing a member GUIObject or GUIItem named '%s', but got a %s-type under that name instead!", self.classname, memberObjectName, GetTypeName(memberThing)), errorDepth)
    end
    
    local propertyNameOtherObject = self[GetCompositeClassPropertyOtherName(propertyNameThisObject)] or propertyNameThisObject
    
    local theirEventName = GetChangedEventNameForProperty(propertyNameOtherObject)
    local ourEventName = GetChangedEventNameForProperty(propertyNameThisObject)
    
    -- Determine if this event forwarding is already setup.
    if self.hooks then
        for i=1, #self.hooks do
            local hook = self.hooks[i]
            if hook.sender == memberThing and
               hook.receiver == self and
               hook.eventName == ourEventName and
               hook.forwardedEventName == theirEventName then
            
                return true
            end
        end
    end
    
    -- If we didn't find an existing callback, hook it up now.
    local callback = self:ForwardEvent(memberThing, theirEventName, ourEventName)
    
    -- Attach the forwarded event name so we can access it later.  Otherwise, it would only exist
    -- inside the function, and it's not easy/performant to dig around inside its upvalues...
    callback.forwardedEventName = theirEventName
    
    return true
    
end

-- Called after the GUIObject and all of its children have been created.
-- NOTE:  At this stage, the object does not yet have a parent.
function GUIObject:_PostInit(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    -- Create all the composite property event forwards.
    if self._classCompositePropList then
        for i=1, #self._classCompositePropList do
            local propertyNameThisObject = self._classCompositePropList[i]
            
            local result = ForwardEventForCompositeClassPropertyChangeEvent(self, propertyNameThisObject, errorDepth)
            if result == nil then
                local memberObjectName = self[GetCompositeClassPropertyFieldName(propertyNameThisObject)]
                error(string.format("Class '%s' declared a composite property referencing a member GUIObject or GUIItem named '%s', but was nil after initialization.", self.classname, memberObjectName), errorDepth)
            end
        end
    end
    
    -- Mark this as done initializing.
    self._initialized = true
    
end

local function GetGUIItemChildren(item)
    
    item:GetChildren(guiItemArray)
    local result = GUIItemArrayToTable(guiItemArray)
    return result

end

-- Recursively traverses the GUIItem hierarchy in a depth-first order, adding GUIItems that belong
-- to this object to the list, and terminating the search when an item is reached that does not
-- belong to this object.
local function GetOwnedGUIItemsHelper(guiObject, list, parentItem)
    
    assert(parentItem)
    
    local children = GetGUIItemChildren(parentItem)
    
    for i=1, #children do
        local owner = GetOwningGUIObject(children[i])
        if owner == guiObject then
            table.insert(list, children[i])
            GetOwnedGUIItemsHelper(guiObject, list, children[i])
        end
    end
    
end

local function GetOwnedGUIItems(guiObject)
    
    local list = { guiObject:GetRootItem() }
    GetOwnedGUIItemsHelper(guiObject, list, guiObject:GetRootItem())
    
    return list
    
end

local function GetChildGUIObjects(guiObject, ownedGUIItems)
    
    local childObjs = {}
    
    for i=1, #ownedGUIItems do
        local children = GetGUIItemChildren(ownedGUIItems[i])
        for j=1, #children do
            local owner = GetOwningGUIObject(children[j])
            if owner ~= guiObject then
                table.insert(childObjs, owner)
            end
        end
    end
    
    return childObjs
    
end

local function DestroyGUIItemActual(guiItem)
    
    assert(guiItemToGUIObjectMapping[guiItem] == nil)
    GUI.DestroyItem(guiItem)
    
end

-- Called at the end of the frame, after everything else that could possibly want anything to do
-- with this object has made their peace.
local function FinishDestruction(self)
    
    self.destroyed = true
    
    -- Destroy all the GUIItems that this object owns.  This is as simple as destroying the
    -- rootItem.  The engine destroys all child GUIItems when a GUIItem is destroyed, but first, we
    -- need to release our ownership of all these items.  Use the lists we gathered earlier.
    for i=1, #self._ownedGUIItems do
        assert(guiItemToGUIObjectMapping[self._ownedGUIItems[i]] == self)
        guiItemToGUIObjectMapping[self._ownedGUIItems[i]] = nil
    end
    self._ownedGUIItems = nil
    
    guiItemToGUIObjectMapping[self.rootItem] = nil
    DestroyGUIItemActual(self.rootItem)
    self.rootItem = nil
    
end

-- Destroys this GUIObject as well as all of its children.
function GUIObject:Destroy()
    
    AssertIsNotDestroyed(self) -- GUIObject cannot be destroyed more than once.
    assert(self._preDestroy == nil)
    self._preDestroy = true
    
    -- Derived classes should extend Uninitialize to perform clean up.  This is performed _BEFORE_
    -- children are destroyed.
    self:Uninitialize()
    
    -- We need to destroy GUIObjects in a depth-first order.  In order to do this, we need to build
    -- a list of direct child GUIObjects for this object (that is, objects whose rootItems are
    -- descendants of this object's rootItem).  It's not as simple as just checking every child's
    -- owner -- sometimes a GUIObject's parent can be a non rootItem item in the parent GUIObject.
    local ownedGUIItems = GetOwnedGUIItems(self)
    self._ownedGUIItems = ownedGUIItems
    local childObjs = GetChildGUIObjects(self, ownedGUIItems)
    
    -- Disable all interactions for these items.
    for i=1, #ownedGUIItems do
        local item = ownedGUIItems[i]
        for j=1, 10 do
            item:ClearOptionFlag(GUIItem["Interaction_"..tostring(j)])
        end
    end
    
    -- Now we have a list of direct descendant GUIObjects.  We will recurse into this list to
    -- destroy GUIObjects in a depth-first order, but there's a problem.  It's totally possible for
    -- a child object's destruction to cause one of its siblings to be destroyed as well, thus
    -- invalidating our list while we're iterating over it!  Have to be careful.  To ensure we are
    -- alerted if this happens, hook the OnDestroyed events for the child objects, and have THOSE
    -- remove the object from the list, and we'll just always destroy the last object in the list
    -- instead of iterating like normal.
    local function OnChildObjectDestroyed(parentObj, childObjBeingDestroyed)
        -- Iterate backwards simply b/c it's more likely the one at the end is the one being
        -- destroyed -- find it faster this way.
        for i=#childObjs, 1, -1 do
            if childObjs[i] == childObjBeingDestroyed then
                table.remove(childObjs, i)
                return
            end
        end
        assert(false) -- a child object MUST have been destroyed and removed from the list.
    end
    
    for i=1, #childObjs do
        self:HookEvent(childObjs[i], "OnDestroy", OnChildObjectDestroyed)
    end
    
    -- Recursively destroy children.
    while #childObjs > 0 do
        childObjs[#childObjs]:Destroy()
    end
    
    -- Orphan this object (remove its parent).  This will also trigger any "OnChildRemoved" events
    -- to fire.
    self:SetParent(nil)
    
    -- Object (should) no longer have any ties to any children or parents.  Safe to destroy now.
    self:FireEvent("OnDestroy", self)
    
    -- Inform the managers just before we destroy this object.
    OnGUIObjectDestroyed(self)
    
    -- Make this object stop listening for events for all other objects.
    self:UnHookAllEvents()
    
    -- Make all listeners of this object stop listening.
    self:RemoveAllListeners()
    
    assert(self.hooks == nil)
    assert(self.callbacks == nil)
    
    -- Ensure object is not modal.
    self:ClearModal()
    
    -- Defer actual destruction to the end of the frame.
    self:EnqueueDeferredUniqueCallback(FinishDestruction)
    
end

-- Derived classes should extend Uninitialize to perform clean up.
function GUIObject:Uninitialize()
end

-- Returns true if the GUIObject has been destroyed (and this is therefore an invalid reference).
function GUIObject:GetIsDestroyed()
    return self.destroyed == true
end

-- Creates a new GUIItem to be managed by this GUIObject.  It will be made a child of this object's
-- root item, unless a different GUIItem is specified.
function GUIObject:CreateGUIItem(optionalParentItem)
    AssertIsNotDestroyed(self)
    local newItem = GUI.CreateItem()
    newItem:SetOptionFlag(GUIItem.CorrectScaling)
    newItem:SetOptionFlag(GUIItem.CorrectRotationOffset)
    
    if optionalParentItem then
        optionalParentItem:AddChild(newItem)
    else
        local parentItem = self:GetChildHoldingItem()
        
        -- This might BE the root item we're creating now... a bit of a wrinkle, but not too bad.
        if parentItem then
            parentItem:AddChild(newItem)
        end
    end
    
    -- Keep track of which items belong to which objects.
    guiItemToGUIObjectMapping[newItem] = self
    
    return newItem
end

-- Creates a new GUIItem for text to be managed by this GUIObject, and optionally sets its parent
-- to the given parent item.
function GUIObject:CreateTextGUIItem(optionalParentItem)
    AssertIsNotDestroyed(self)
    local newItem = self:CreateGUIItem(optionalParentItem)
    SetupGUIItemForText(newItem)
    return newItem
end

-- Creates a new, invisible GUIItem (to help position other items) to be managed by this GUIObject,
-- and optionally sets its parent to the given parent item.
function GUIObject:CreateLocatorGUIItem(optionalParentItem)
    AssertIsNotDestroyed(self)
    local newItem = self:CreateGUIItem(optionalParentItem)
    SetupGUIItemForLocator(newItem)
    return newItem
end

function GUIObject:DestroyGUIItem(guiItem)
    
    AssertIsaGUIItem(guiItem)
    
    local owningObject = GetOwningGUIObject(guiItem)
    if owningObject == nil then
        error("Attempted to destroy a GUIItem with GUIObject.DestroyGUIItem that was not created by this GUI system!", 2)
    elseif owningObject ~= self then
        error("GUIObject attempted to destroy a GUIItem it does not own!", 2)
    end
    
    guiItemToGUIObjectMapping[guiItem] = nil
    
    DestroyGUIItemActual(guiItem)
    
end

Event.Hook("NotifyGUIItemDestroyed", function(destroyedItem)
    
    -- See if our new gui system owned this item.
    local owningObject = GetOwningGUIObject(destroyedItem)
    if not owningObject then
        return
    end
    
    -- GUIObject:DestroyGUIItem() will remove its reference to the item in the system.  If we made
    -- it this far, it means the item still belongs to the system, and that it was destroyed from
    -- outside the system.
    error("GUIItem belonging to this system was destroyed by a call from outside the system!  (ALL GUIItem handling for this system MUST be performed using a corresponding GUIObject method).")
    
end)

function GUIObject:GetIsDescendantOf(ancestorObj)
    
    PROFILE("GUIObject:GetIsDescendantOf")
    
    RequireIsa("GUIObject", ancestorObj, "ancestorObj")
    
    local currentObj = self
    while currentObj do
        local parent = currentObj:GetParent()
        if parent == ancestorObj then
            return true
        end
        currentObj = parent
    end
    
    return false
    
end

function GUIObject:GetIsAncestorOf(descendantObj)
    
    PROFILE("GUIObject:GetIsAncestorOf")
    
    local result = descendantObj:GetIsDescendantOf(self)
    return result
    
end

function GUIObject:GetName()
    return self.name
end

-- Returns the screen-space position of the object.  By default, returns the screen space position
-- of the upper-left corner of the object, but can be modified to return other positions by feeding
-- normalized coordinates (hot spot) to optionalHotSpotX, and optionalHotSpotY parameters.  Also
-- accepts a Vector object as the first parameter.
function GUIObject:GetScreenPosition(optionalHotSpotX, optionalHotSpotY)
    
    local hotspot
    if optionalHotSpotX ~= nil then
        hotspot = ProcessVectorInput(optionalHotSpotX, optionalHotSpotY)
    end
    
    -- Temporarily un-adjust the GUIItem's position and size to make the engine calculate this for
    -- us.  Move it back when we're done just before returning.  We include size because a hotspot
    -- might have been included.
    local oldPos = self:GetRootItem():GetPosition()
    local newPos = self:GetPosition()
    local oldSize = self:GetRootItem():GetSize()
    local newSize = self:GetSize()
    
    self:GetRootItem():SetPosition(newPos)
    self:GetRootItem():SetSize(newSize)
    local screenPos = self:GetRootItem():GetScreenPosition(nil, nil, hotspot)
    self:GetRootItem():SetPosition(oldPos)
    self:GetRootItem():SetSize(oldSize)
    
    return screenPos
    
end

function GUIObject:ScreenSpaceToLocalSpace(p1, p2)
    
    local ssPt = ProcessVectorInput(p1, p2)
    local screenPos = self:GetScreenPosition()
    local scale = self:GetAbsoluteScale()
    
    return (ssPt - screenPos) / scale
    
end

function GUIObject:ScreenSpaceToLocalSpaceStatic(p1, p2)
    
    local ssPt = ProcessVectorInput(p1, p2)
    local screenPos = GetStaticScreenPosition(self)
    local scale = GetStaticAbsoluteScale(self)
    
    return (ssPt - screenPos) / scale
    
end

function GUIObject:LocalSpaceToScreenSpace(p1, p2)
    
    local osPt = ProcessVectorInput(p1, p2)
    local screenPos = self:GetScreenPosition()
    local scale = self:GetAbsoluteScale()
    
    return osPt * scale + screenPos
    
end

function GUIObject:LocalSpaceToScreenSpaceStatic(p1, p2)
    
    local osPt = ProcessVectorInput(p1, p2)
    local screenPos = GetStaticScreenPosition(self)
    local scale = GetStaticAbsoluteScale(self)
    
    return osPt * scale + screenPos

end

-- Called to confirm that the given point is indeed over the object.  Most of the time this should
-- just return true, but in the case of oddly-shaped objects (eg trapezoidal button), it may be
-- necessary to further refine the shape from inside the GUIItem it resides in.  To be clear, the
-- GUIItem's rectangular shape should bound the more complex shape -- this method is only ever
-- called if the point is at least inside the rectangle.
function GUIObject:IsPointOverObject(pt)
    return not self.destroyed
end

-- Returns the GUIItem at the root of this GUIObject.
function GUIObject:GetRootItem()
    AssertIsNotDestroyed(self)
    return self.rootItem
end

-- Returns the GUIItem that child items should be added to.  Usually just the root item, but can be
-- overridden for more complex objects (eg GUIScrollPane).
function GUIObject:GetChildHoldingItem()
    AssertIsNotDestroyed(self)
    return self.rootItem
end

-- Accepts either a GUIObject, GUIItem, or nil.  Sets the rootItem's parent to the item if it's a
-- GUIItem, or to the root item of the given GUIObject.  Clears the parent if nil.  Some GUIObjects
-- take extra parameters when adding children (eg GUIFillLayout takes a weight).  These are passed
-- along when the OnChildAdded event is fired.
function GUIObject:SetParent(parentObjOrItemOrNil, params)
    
    local parentItem
    if GetIsaGUIObject(parentObjOrItemOrNil) then
        parentItem = parentObjOrItemOrNil:GetRootItem()
    elseif GetIsaGUIItem(parentObjOrItemOrNil) then
        parentItem = parentObjOrItemOrNil
    elseif parentObjOrItemOrNil ~= nil then
        error(string.format("Expected a GUIItem or GUIObject, got %s-type instead.", GetTypeName(parentObjOrItemOrNil)), 2)
    end
    
    -- Notify old parent we are removing ourselves.
    local oldParentObject = self:GetParent()
    local oldParentItem = oldParentObject and oldParentObject:GetChildHoldingItem()
    
    -- If the parent is the same, bail out now.
    if oldParentItem == parentItem then
        return
    end
    
    -- Set this object's root item's parent to the parent item.
    if parentItem == nil then
        assert(oldParentItem ~= nil) -- otherwise we'd have bailed out above...
        oldParentItem:RemoveChild(self:GetRootItem())
    else
        parentItem:AddChild(self:GetRootItem())
    end
    
    if oldParentObject then
        oldParentObject:FireEvent("OnChildRemoved", self:GetRootItem())
    end
    
    local newParentObject = parentItem and GetOwningGUIObject(parentItem)
    if newParentObject then
        newParentObject:FireEvent("OnChildAdded", self:GetRootItem(), params)
    end
    
    self:FireEvent("OnParentChanged", newParentObject, oldParentObject)
    
end

-- Get the parent GUIObject (based on root item hierarchy).
function GUIObject:GetParent(suppressInitWarning)
    
    if not self._initialized and not suppressInitWarning then
        Log("WARNING!  New object called GetParent() before initialization was completed.  This will always return nil!")
        Log("%s", debug.traceback())
    end
    
    local rootItem = self:GetRootItem()
    assert(rootItem)
    local parentItem = rootItem:GetParent()
    if parentItem == nil then
        return nil
    end
    local result = GetOwningGUIObject(parentItem)
    return result
end

-- Get child object by name.  Can also check if the child's name is unique among its siblings.
function GUIObject:GetChild(name, checkForUnique)
    self:GetRootItem():GetChildren(guiItemArray)
    local childObj, isUnique = FindObjectWithNameInGUIItemArray(guiItemArray, name, checkForUnique)
    return childObj, isUnique
end

-- Get the GUIObject responsible for this item.  Returns nil if the item is not owned by a
-- GUIObject (guaranteed to not happen in pure "new" system... but any items created by the old
-- system will not have any GUIObjects associated with them).
function GetOwningGUIObject(item)
    
    AssertIsaGUIItem(item)
    
    return guiItemToGUIObjectMapping[item]
    
end

-- Create pass-through methods for GUIItem methods that are not represented as fake properties for
-- this GUIObject.  All these do is call the corresponding GUIItem method for the root item of this
-- GUIObject.
do
    local passThroughMethods =
    {
        "ClearCropRectangle",
        "ForceUpdateTextSize",
        "GetTextureHeight",
        "GetTextureWidth",
        "SetFloat2Parameter",
        "SetFloat3Parameter",
        "SetFloat4Parameter",
        "SetFloatParameter",
        "GetAbsoluteScale",
        "GetAbsoluteSize",
        "GetWasRenderedLastFrame",
        "CalculateTextSize",
        "SetTexturePixelCoordinates",
        "SetTextureCoordinates",
        "SetAdditionalTexture",
    }
    for i=1, #passThroughMethods do
        GUIObject[ passThroughMethods[i] ] =
            function(self, p1, p2, p3, p4, p5)
                local result = GUIItem[ passThroughMethods[i] ](self:GetRootItem(), p1, p2, p3, p4, p5)
                return result
            end
    end
end


----------------------------------------------------------------------------------------------------
-------------------------------------- EVENT CALLBACK METHODS --------------------------------------
----------------------------------------------------------------------------------------------------


-- Called every single frame that the mouse is hovering directly over this object, except for when
-- this object is being pressed/dragged/held-down.
function GUIObject:OnMouseHover()
    self:FireEvent("OnMouseHover")
end

-- Called when the mouse begins hovering directly over this object.
function GUIObject:OnMouseEnter()
    self:FireEvent("OnMouseEnter")
end

-- Called when the mouse -- which had last frame been hovering directly over this object -- is no
-- longer hovering over this object.
function GUIObject:OnMouseExit()
    self:FireEvent("OnMouseExit")
end

-- Called when the left mouse button is clicked _DOWN_ onto this object.
-- double -- boolean, true = this is a double-click, false = this is a regular click.
function GUIObject:OnMouseClick(double)
    self:FireEvent("OnMouseClick", double)
end

-- Return whether or not this item can be double-clicked.  If true, this means a click within
-- a certain time of a previous click will be considered a double click when over this object, and
-- the call to OnMouseClick() for this object will have the "double" parameter set to true.
-- If false, it means all clicks on this object, regardless of frequency, will register as normal
-- single clicks.  This distinction is important as double-clicks will NOT have a corresponding
-- OnMouseUp or OnMouseRelease or OnMouseCancel event, therefore it is not safe to simply ignore
-- the "double" parameter in OnMouseClick.
function GUIObject:GetCanBeDoubleClicked()
    return false
end

-- Called every single frame that the mouse is clicked down for the object that it was originally
-- clicked down on (regardless of whether or not the cursor is _still_ over the object).  This is
-- called every frame instead of just the frames where the mouse has moved, since sometimes it is
-- necessary when more than just the mouse can move (for example, if a slider object moves while
-- the mouse is interacting with it).
function GUIObject:OnMouseDrag()
    self:FireEvent("OnMouseDrag")
end

-- Called when the left mouse button is released over this object, after having previously been
-- clicked down onto this object.
function GUIObject:OnMouseRelease()
    self:FireEvent("OnMouseRelease")
end

-- Called when the left mouse button is released elsewhere, not over this object, after having
-- previously been clicked down on this object.
function GUIObject:OnMouseCancel()
    self:FireEvent("OnMouseCancel")
end

-- Called when the left mouse button is released, regardless of location, after having previously
-- been clicked down on this object.  Called after OnMouseCancel() or OnMouseRelease().
function GUIObject:OnMouseUp()
    self:FireEvent("OnMouseUp")
end

-- Called when the mouse wheel is rolled with the cursor hovering over this object. If this
-- method returns true or nil, the event is consumed.  If it returns false, the event is _not_
-- consumed, and will proceed to the next-highest GUIItem to be eligible to receive it.
-- up -- boolean, true = mouse wheel was rolled up, false = mouse wheel was rolled down.
function GUIObject:OnMouseWheel(up)
    self:FireEvent("OnMouseWheel", up)
end

-- Called when a key (other than the left mouse button) is pressed or released.  If this method
-- returns true or nil, the event is consumed.  If it returns false, the event is _not_ consumed,
-- and will proceed to the next-highest GUIItem to be eligible to receive it.
-- key -- key code of the key that was pressed or released.
-- down -- boolean, true = key was pressed down, false = key was released.
function GUIObject:OnKey(key, down)
    self:FireEvent("OnKey", key, down)
end

-- Called when a character is typed in by the user.  This will only occur after
-- GUIObject:ListenForCharacters() is called for this object.
-- character -- the character that was received, as a utf-8 string (ie #character might be > 1).
function GUIObject:OnCharacter(character)
    self:FireEvent("OnCharacter", character)
end

-- Called when this object is modal and the mouse is clicked down outside of the object.
function GUIObject:OnOutsideClick()
    self:FireEvent("OnOutsideClick")
end

-- Called when this object is modal and the mouse wheel is rolled outside of the object.
function GUIObject:OnOutsideWheel(up)
    self:FireEvent("OnOutsideWheel", up)
end


----------------------------------------------------------------------------------------------------
------------------------------------------ EVENT METHODS -------------------------------------------
----------------------------------------------------------------------------------------------------


-- This object will begin receiving cursor-related events from the given GUIItem.  This means that
-- the object will now receive the following method calls for events:
--      IsPointOverObject()
--      OnMouseHover()
--      OnMouseEnter()
--      OnMouseExit()
--      OnMouseClick()
--      OnMouseRelease()
--      OnMouseCancel()
--      OnMouseUp()
-- NOTE: For each "type" of listening (cursor, wheel, or key), a GUIItem can only be listened to by
-- one GUIObject.
function GUIObject:ListenForCursorInteractions(triggeringItem)
    AssertIsNotDestroyed(self)
    GetGUIInteractionManager():ListenForMouseCursor(self, triggeringItem or self:GetRootItem())
end

-- This object will begin receiving mouse-wheel-related events from the given GUIItem.  This means
-- that the object will now receive the following method calls for events:
--      IsPointOverObject()
--      OnMouseWheel()
-- NOTE: For each "type" of listening (cursor, wheel, or key), a GUIItem can only be listened to by
-- one GUIObject.
function GUIObject:ListenForWheelInteractions(triggeringItem)
    AssertIsNotDestroyed(self)
    GetGUIInteractionManager():ListenForMouseWheel(self, triggeringItem or self:GetRootItem())
end

-- This object will begin receiving key-related events from the given GUIItem.  This means that the
-- object will now receive the following method calls for events:
--      OnKey()
-- NOTE: For each "type" of listening (cursor, wheel, or key), a GUIItem can only be listened to by
-- one GUIObject.
function GUIObject:ListenForKeyInteractions(triggeringItem)
    AssertIsNotDestroyed(self)
    GetGUIInteractionManager():ListenForKey(self, triggeringItem or self:GetRootItem())
end

-- Causes this GUIObject (or GUIItem if item is provided instead) to block all interactions with
-- its children -- children (and their descendants) will no longer receive keyboard, cursor, or
-- wheel events.  This item, however, will still receive events -- although it is not required to
-- in order to block.
function GUIObject:BlockChildInteractions(optionalItem)
    
    local item
    if optionalItem == nil then
        item = self:GetRootItem()
    elseif GetIsaGUIItem(optionalItem) then
        item = optionalItem
    else
        error(string.format("Expected a GUIItem, or nil (to reference self), got %s-type instead!", GetTypeName(optionalItem)), 2)
    end
    
    GetGUIInteractionManager():BlockChildInteractions(item)
    
end

--- This GUIObject or GUIItem will no longer block interactions with its children.
---@param optionalItem GUIItem | GUIObject | nil
function GUIObject:AllowChildInteractions(optionalItem)
    
    local item
    if optionalItem == nil then
        item = self:GetRootItem()
    elseif GetIsaGUIItem(optionalItem) then
        item = optionalItem
    else
        error(string.format("Expected a GUIItem, or nil (to reference self), got %s-type instead!", GetTypeName(optionalItem)), 2)
    end
    
    GetGUIInteractionManager():AllowChildInteractions(item)
    
end

-- This object will stop receiving cursor-related interactions from the given GUIItem.
function GUIObject:StopListeningForCursorInteractions(triggeringItem)
    GetGUIInteractionManager():StopListeningForMouseCursor(self, triggeringItem or self:GetRootItem())
end

-- This object will stop receiving mouse-wheel-related interactions from the given GUIItem.
function GUIObject:StopListeningForWheelInteractions(triggeringItem)
    GetGUIInteractionManager():StopListeningForMouseWheel(self, triggeringItem or self:GetRootItem())
end

-- This object will stop receiving key-related interactions from the given GUIItem.
function GUIObject:StopListeningForKeyInteractions(triggeringItem)
    GetGUIInteractionManager():StopListeningForKey(self, triggeringItem or self:GetRootItem())
end

-- This object will begin receiving keyboard-input.  It will continue to receive characters from
-- the keyboard until GUIObject:StopListeningForCharacters() is called.  It will not receive
-- characters if another object calls GUIObject:ListenForCharacters() after this object, however
-- will begin to receive characters once again when the other object calls
-- GUIObject:StopListeningForCharacters().
function GUIObject:ListenForCharacters()
    AssertIsNotDestroyed(self)
    assert(self.listeningForCharacters == nil)
    self.listeningForCharacters = true
    GetGUIInteractionManager():AddGUIObjectToCharacterReceiverStack(self)
end

-- This object will no longer receive characters entered from the keyboard.
function GUIObject:StopListeningForCharacters()
    assert(self.listeningForCharacters == true)
    self.listeningForCharacters = nil
    GetGUIInteractionManager():RemoveGUIObjectFromCharacterReceiverStack(self)
end

-- This object and its descendants will receive events exclusively -- other objects will not
-- receive events.  This is useful in situations where the user must provide some input before
-- proceeding (eg don't allow user to edit two text fields at a time).  If two objects call
-- SetModal, the last will receive events exclusively, and the former will only receive events once
-- the latter's ClearModal() is called.  It functions like a stack.
function GUIObject:SetModal()
    
    AssertIsNotDestroyed(self)
    
    if self.modal then
        return -- already modal.
    end
    
    self.modal = true
    
    GetGUIInteractionManager():AddGUIObjectToModalObjectStack(self)
    if self.altModalObj then
        self.altModalObj:SetModal()
    end
    
end

-- This object will stop receiving events exclusively.
function GUIObject:ClearModal()
    
    if not self.modal then
        return -- already not modal.
    end
    
    self.modal = nil
    
    if self.altModalObj then
        self.altModalObj:ClearModal()
    end
    GetGUIInteractionManager():RemoveGUIObjectFromModalObjectStack(self)
    
end

-- Sets the GUIObject that will be used for subsequent calls to SetModal() from this object.  This
-- is useful in situations where a widget might become part of a larger widget that should act as a
-- whole.  For example, the GUITextInputWidget is JUST a text item, but it gets used in
-- GUIMenuTextEntryWidget as part of a larger, more complete widget.  For this widget, we can set
-- the modal item to the root item of the larger widget so that interactions on the larger object
-- will still be allowed through.
-- Set to nil to clear the item (will default to using this object's root item).
-- NOTE:  This cannot be called while the object is modal.
function GUIObject:SetModalObject(obj)
    assert(self.modal == nil) -- Cannot change modal object while modal.
    if obj == nil or obj == self then
        self.altModalObj = nil
    else
        AssertIsaGUIObject(obj)
        AssertIsNotDestroyed(self)
        AssertIsNotDestroyed(obj)
        self.altModalObj = obj
    end
end

-- Returns the object that this object will route modal interactions to, if modal.
function GUIObject:GetModalObject()
    if self.altModalObj then
        local result = self.altModalObj:GetModalObject()
        return result
    else
        return self
    end
end

-- Prevents OnMouseRelease from being called if the event manager considers this to be the
-- currently "clicked down on" object, otherwise it does nothing.
function GUIObject:CancelPendingMouseRelease()
    
    local targetObj = self:GetModalObject()
    GetGUIInteractionManager():CancelPendingMouseRelease(targetObj)
    
end

local function FireEventActual(self, managerFunc, eventName, p1, p2, p3, p4, p5, p6, p7, p8)
    
    AssertIsNotDestroyed(self)
    
    if not self.callbacks then
        return -- nothing is listening to this object.
    end
    
    -- Don't immediately fire events as we iterate; queue them up instead.  It is entirely possible
    -- for a receiver to be removed as a result of an event call, and that would mess up iteration.
    for i=1, #self.callbacks do
        
        local callback = self.callbacks[i]
        
        -- Only add callbacks that are applicable here.
        if callback.eventName == eventName then
            managerFunc(GetGUIEventManager(), callback, p1, p2, p3, p4, p5, p6, p7, p8)
        end
        
    end
    
    -- Process all queued events (unless this object has temporarily paused event processing).
    if not self.eventsPaused then
        GetGUIEventManager():ProcessEventQueue()
    end
    
end

-- Fires an event off to all of the listeners of the given eventName listening to this object.
-- The parameters p1..p8 are for a variable number of parameters and are purely optional.
function GUIObject:FireEvent(eventName, p1, p2, p3, p4, p5, p6, p7, p8)
    FireEventActual(self, GUIEventManager.EnqueueEventCallback, eventName, p1, p2, p3, p4, p5, p6, p7, p8)
end

-- Fires an event off to all of the listeners of the given eventName listening to this object.
-- If any events with the same name are queued up, it will unqueue them, ensuring that only the
-- last scheduled event actually fires.
function GUIObject:FireUniqueEvent(eventName, p1, p2, p3, p4, p5, p6, p7, p8)
    FireEventActual(self, GUIEventManager.EnqueueUniqueEventCallback, eventName, p1, p2, p3, p4, p5, p6, p7, p8)
end

-- Enqueues a callback function to fire at the end of this update cycle, after all other events
-- have fired.  The parameter passed to the callback function when it fires is this object, as it
-- is assumed the callback function is a method of this object.
function GUIObject:EnqueueDeferredUniqueCallback(callbackFunction)
    
    local callback =
    {
        param = self,
        callbackFunction = callbackFunction,
    }
    GetGUIDeferredUniqueCallbackManager():EnqueueDeferredUniqueCallback(callback)
    
end

-- Prints debug information about each callback for the given event.  Used to get a list of all the
-- functions that get called when an event fires, for debugging.
function GUIObject:Debug_DumpCallbackInfo(eventName)
    
    Log("Debug_DumpCallbackInfo()")
    Log("    self = %s", Debug_GetBKAForItem(self:GetRootItem()))
    Log("    eventName = %s", eventName)
    Log("    #self.callbacks = %s", #self.callbacks)
    
    local callbackCount = 0
    for i=1, #self.callbacks do
        local callback = self.callbacks[i]
        if callback.eventName == eventName then
            callbackCount = callbackCount + 1
        end
    end
    
    Log("    applicable callback count = %s", callbackCount)
    
    for i=1, #self.callbacks do
        local callback = self.callbacks[i]
        if callback.eventName == eventName then
            Log("    callback[%s]:", i)
            Log("        sender = %s", Debug_GetBKAForItem(callback.sender:GetRootItem()))
            Log("        receiver = %s", Debug_GetBKAForItem(callback.receiver:GetRootItem()))
            Log("        eventName = %s", callback.eventName)
            local callbackFunction = callback.callbackFunction
            Log("        callbackFunction = %s", DebugFunctionToString(callbackFunction))
            
        end
    end
    
end

-- This object will continue to queue up events to fire, but will not actually fire them.  Event
-- queue will resume processing when GUIObject:ResumeEvents() is called.  NOTE: This only prevents
-- THIS object from telling the event manager to process the event queue.  This does not prevent
-- other objects from telling the event manager to start processing events.  Typically this
-- limitation shouldn't matter, as this pause/resume feature is intended to delay callbacks from
-- within a single function call (eg to ensure that related state is in sync before callbacks are
-- fired).
function GUIObject:PauseEvents()
    
    AssertIsNotDestroyed(self)
    
    self.eventsPaused = (self.eventsPaused or 0) + 1
    
end

function GUIObject:ResumeEvents()
    
    AssertIsNotDestroyed(self)
    
    assert(self.eventsPaused ~= nil)
    assert(self.eventsPaused > 0)
    
    self.eventsPaused = self.eventsPaused - 1
    if self.eventsPaused == 0 then
        self.eventsPaused = nil
    end
    
    -- Process all queued events.
    GetGUIEventManager():ProcessEventQueue()
    
end

-- Returns true if the object is still being initialized, false if _PostInit has finished running.
-- This should not be overridden by other classes.
function GUIObject:GetIsInitializing()
    return not self._initialized
end

-- Returns the property name if true, otherwise returns nil.
local function GetEventNameFromCompositeClassPropertyChangedEvent(self, eventName)
    
    PROFILE("GUIObject GetEventNameFromCompositeClassPropertyChangedEvent")
    
    -- Find the one with the On_____Changed event that matches this one.  This could be optimized
    -- by pre-computing the list of event names for each class when the composite class properties
    -- are declared... but let's see if we can get away without doing this.
    if self._classCompositePropList then
        for i=1, #self._classCompositePropList do
            local propertyName = self._classCompositePropList[i]
            local changedEventName = GetChangedEventNameForProperty(propertyName)
            if changedEventName == eventName then
                return propertyName
            end
        end
    end
    
    return nil
    
end

-- Sets up a callback for when the sender GUIObject fires an event called eventName.
-- Callback function should have the following signature:
--      callbackFunction(self, param1, param2... param8)
-- The parameter "self" is the receiver of the event (the one calling HookEvent here).
-- The "param" parameters are optional.
function GUIObject:HookEvent(sender, eventName, callbackFunction)
    
    AssertIsNotDestroyed(self)
    
    -- Validate input
    AssertIsaGUIObject(sender)
    
    if type(eventName) ~= "string" then
        error(string.format("Expected a string for eventName, got %s-type instead.", GetTypeName(eventName)), 2)
    end
    
    if type(callbackFunction) ~= "function" then
        error(string.format("Expected a function for callbackFunction, got %s-type instead.", GetTypeName(callbackFunction)), 2)
    end
    
    -- If this class is still being initialized, check and see if this event hook is for a
    -- composite class property's On_____Changed event -- which won't have been hooked up yet -- 
    -- and see if we can hook it up now, early.
    if self:GetIsInitializing() and not self._forwardingEvent then
        
        local propertyName = GetEventNameFromCompositeClassPropertyChangedEvent(self, eventName)
        if propertyName then -- nil if not from a composite class property
            ForwardEventForCompositeClassPropertyChangeEvent(self, propertyName)
        end
        
    end
    
    -- Create a new callback.
    local newCallback = {}
    newCallback.sender = sender
    newCallback.receiver = self
    newCallback.eventName = eventName
    newCallback.callbackFunction = callbackFunction
    
    -- Only create the hooks table for objects that actually have hooks -- most won't.
    if not self.hooks then
        self.hooks = {}
    end
    table.insert(self.hooks, newCallback)
    
    -- Sender object also keeps a record of their listeners.
    if not sender.callbacks then
        sender.callbacks = {}
    end
    
    table.insert(sender.callbacks, newCallback)
    
    return newCallback
    
end

-- Sets up automatic forwarding of the given event from the sender.  Simply calls HookEvent() for
-- the event, and sets up a callback that fires the event immediately.
-- An alternate event name can be provided to alter the event that the receiver sees.
-- For example, ForwardEvent(x, "A", "B") will cause this object to receive "A" events from object
-- x, and immediately send them back out as "B" events.  If "B" was omitted, it would send out "A"
-- events.
function GUIObject:ForwardEvent(sender, eventName, alternateEventName)
    local eventNameToReceiver = alternateEventName or eventName
    
    self._forwardingEvent = true
    local result = self:HookEvent(sender, eventName,
        function(self, p1, p2, p3, p4, p5, p6, p7, p8)
            self:FireEvent(eventNameToReceiver, p1, p2, p3, p4, p5, p6, p7, p8)
        end)
    self._forwardingEvent = nil
    
    return result
    
end

-- Stops listening to all events with the given name.  Returns false if it had no effect.
function GUIObject:UnHookEventsByName(eventName)
    if type(eventName) ~= "string" then
        error(string.format("Expected a string for eventName, got %s-type instead.", GetTypeName(eventName)), 2)
    end
    local result = self:UnHookEvent(nil, eventName, nil)
    return result
end

-- Stops listening to all events from the given sender.  Returns false if it had no effect.
function GUIObject:UnHookEventsBySender(sender)
    AssertIsaGUIObject(sender)
    local result = self:UnHookEvent(sender, nil, nil)
    return result
end

-- Stop listening to all events that use the given callback function.  Returns false if it had no
-- effect.
function GUIObject:UnHookEventsByCallbackFunction(callbackFunction)
    assert(type(callbackFunction) == "function")
    local result = self:UnHookEvent(nil, nil, callbackFunction)
    return result
end

-- Stops listening to all events that match the given callback (the return value of a
-- GUIObject:HookEvent() call).  Returns false if it had no effect.
function GUIObject:UnHookEventsByCallback(callback)
    assert(type(callback) == "table")
    assert(type(callback.eventName) == "string")
    assert(type(callback.callbackFunction) == "function")
    assert(GetIsaGUIObject(callback.sender))
    local result = self:UnHookEvent(callback.sender, callback.eventName, callback.callbackFunction)
    return result
end

-- Stops listening to all events.  Returns false if it had no effect.
function GUIObject:UnHookAllEvents()
    local result = self:UnHookEvent()
    return result
end

-- Performs the actual un-hooking of events.
local function RemoveCallback(callback, receiverIdx, senderIdx)
    
    local sender = callback.sender
    local receiver = callback.receiver
    
    -- Pass receiver index if we have it, so we don't have to iterate over them redundantly.
    if receiverIdx == nil then
        for i=1, #receiver.hooks do
            if receiver.hooks[i] == callback then
                receiverIdx = i
                break
            end
        end
    end
    assert(receiver.hooks[receiverIdx] == callback)
    
    -- Pass sender index if we have it, so we don't have to iterate over them redundantly.
    if senderIdx == nil then
        for i=1, #sender.callbacks do
            if sender.callbacks[i] == callback then
                senderIdx = i
                break
            end
        end
    end
    assert(sender.callbacks[senderIdx] == callback)
    
    -- Remove callback from sender's list.
    table.remove(sender.callbacks, senderIdx)
    
    -- Remove callback from receiver's list.
    table.remove(receiver.hooks, receiverIdx)
    
    -- Cleanup sender's table, if possible.
    if #sender.callbacks == 0 then
        sender.callbacks = nil
    end
    
    -- Cleanup receiver's table, if possible.
    if #receiver.hooks == 0 then
        receiver.hooks = nil
    end
    
    -- Inform the event manager that a callback has been deleted (so it can be removed from the
    -- queue).
    GetGUIEventManager():OnCallbackRemoved(callback)
    
end

-- Stop listening to events from sender with the name eventName and using the callbackFunction
-- provided.  All parameters are optional.  Omitted parameters are treated like wildcards.
-- Therefore, passing nil for all parameters removes all hooks, for example.  Returns false if it
-- had no effect.
function GUIObject:UnHookEvent(sender, eventName, callbackFunction)
    
    if eventName ~= nil then
        assert(type(eventName) == "string")
    end
    
    if sender ~= nil then
        AssertIsaGUIObject(sender)
    end
    
    if callbackFunction ~= nil then
        assert(type(callbackFunction) == "function")
    end
    
    if not self.hooks then
        return false -- no hooks.
    end
    
    -- Iterate over all hooks, removing those that fit the criteria provided.
    local found = false
    for i=#self.hooks, 1, -1 do
        
        local callback = self.hooks[i]
        
        if (eventName == nil or eventName == callback.eventName) and
           (sender == nil or sender == callback.sender) and
           (callbackFunction == nil or callbackFunction == callback.callbackFunction) then
            
            RemoveCallback(callback, i)
            found = true
            
        end
        
    end
    
    return found
    
end

-- Removes all listeners from this object.  Returns false if it had no effect.
function GUIObject:RemoveAllListeners()
    
    if not self.callbacks then
        return false
    end
    
    local found = false
    for i=#self.callbacks, 1, -1 do
        RemoveCallback(self.callbacks[i], nil, i)
        found = true
    end
    
    return found
    
end

-- Creates a timed callback that will call the given callbackFunction after delay seconds.  If
-- delay is <= 0, then the callback will fire on the next frame.  If repeat is true, then the
-- callback will cycle every 'delay'-seconds rather than destroying itself after the delay.
-- Returns the callback that was created.  Use this reference to remove it later.
function GUIObject:AddTimedCallback(callbackFunction, delay, rep)
    local result = GetGUITimedCallbackManager():AddTimedCallback(self, callbackFunction, delay, rep)
    return result
end

function GUIObject:RemoveTimedCallback(callback)
    local result = GetGUITimedCallbackManager():RemoveTimedCallback(callback)
    return result
end

function GUIObject:TrackRenderStatus(objOrItem)
    
    local item
    if objOrItem == nil then
        item = self:GetRootItem()
    elseif GetIsaGUIObject(objOrItem) then
        item = objOrItem:GetRootItem()
    else
        AssertIsaGUIItem(objOrItem)
        item = objOrItem
    end
    
    local result = GetGUIRenderedStatusManager():TrackRenderStatusOfObject(self, item)
    return result
    
end

function GUIObject:StopTrackingRenderStatus()
    local result = GetGUIRenderedStatusManager():StopTrackingRenderStatusOfObject(self)
    return result
end

function GUIObject:SetUpdates(state)
    
    if state then
        GetGUIUpdateManager():AddObjectToUpdateSet(self)
    else
        GetGUIUpdateManager():RemoveObjectFromUpdateSet(self)
    end
    
end

local function StopSyncingSizeToParent(self, parentObj)
    
    RequireIsa("GUIObject", parentObj, "parentObj", 2)
    
    self:UnHookEvent(parentObj, "OnSizeChanged", self.SetSize)
    
end

local function BeginSyncingSizeToParent(self, parentObj)
    
    RequireIsa("GUIObject", parentObj, "parentObj", 2)
    
    -- Attempt to remove existing hook, just in case to avoid duplicates.
    StopSyncingSizeToParent(self, parentObj)
    
    -- Set this object's size to the parent's size whenever the parent's size changes.
    self:HookEvent(parentObj, "OnSizeChanged", self.SetSize)
    
    -- Set this object's size to the parent's size right now.
    self:SetSize(parentObj:GetSize())
    
end

local function OnParentChangedForSizeSync(self, newParentObj, oldParentObj)
    
    if oldParentObj then
        StopSyncingSizeToParent(self, oldParentObj)
    end
    
    if newParentObj then
        BeginSyncingSizeToParent(self, newParentObj)
    end
    
end

local function TearDownParentSizeSync(self)
    
    -- Stop listening for parent changes.
    self:UnHookEvent(self, "OnParentChanged", OnParentChangedForSizeSync)
    
    -- Un-hook from current parent, if necessary.
    local parentObj = self:GetParent(true)
    if parentObj then
        StopSyncingSizeToParent(self, parentObj)
    end

end

local function SetupParentSizeSync(self)
    
    -- Just in case.
    TearDownParentSizeSync(self)
    
    -- Listen for parent changes.
    self:HookEvent(self, "OnParentChanged", OnParentChangedForSizeSync)
    
    -- Hook into current parent, if necessary.
    local parentObj = self:GetParent(true)
    if parentObj then
        BeginSyncingSizeToParent(self, parentObj)
    end

end

-- Hooks this object up to always sync its size to that of its parent.  Can be called at any time,
-- even during Initialize() when it doesn't yet have a parent object.  If the parent object changes,
-- it will be synchronized to the new parent.
function GUIObject:SetSyncToParentSize(state)
    
    RequireType("boolean", state, "state", 2)
    
    -- Equate nil with false
    if (self._syncdToParent == true) == state then
        return -- already set to this state.
    end
    
    self._syncdToParent = state
    
    if self._syncdToParent then
        -- Just enabled syncing, sync with parent if we have one.
        SetupParentSizeSync(self)
    else
        -- Just disabled syncing.  Stop syncing with parent if we have one.
        TearDownParentSizeSync(self)
    end
    
end

----------------------------------------------------------------------------------------------------
----------------------------------------- PROPERTY METHODS -----------------------------------------
----------------------------------------------------------------------------------------------------


-- Returns a function to act as a Setter for the given property name.  If a preexisting one cannot
-- be found, a new one is generated.
local autoGeneratedSetters = {}
function GUIObject.GetAutoGeneratedSetter(propertyName, propertyType, itemName, altPropertyName)
    
    assert(type(propertyType) == "string")
    
    itemName = itemName or "rootItem"
    altPropertyName = altPropertyName or propertyName
    local key = propertyName.."_of_"..itemName.."_using_"..altPropertyName
    
    if not autoGeneratedSetters[key] then
        
        local newSetter
        local isFake = GetIsaFakeProperty(altPropertyName)
        local propertySetterFuncActual = isFake and GetFakePropertySetter(itemName) or InstancePropertySetter
        
        if propertyType == "Vector" then
            
            -- Vector-type properties can be set with two or three numbers instead of a Vector type.
            newSetter = function(self, p1, p2, p3)
                local value = ProcessVectorInput(p1, p2, p3)
                local result = PerformSetterDuties(self, propertyName, value, propertySetterFuncActual, altPropertyName)
                return result
            end
            
        elseif propertyType == "Color" then
            
            -- Color-type properties can be set with three or four numbers instead of a Color type.
            newSetter = function(self, p1, p2, p3, p4)
                local value = ProcessColorInput(p1, p2, p3, p4)
                
                -- If they are trying to set the "Color" property of a GUIItem, override the setter.
                -- This is a special exception due to how "Color" is used as a property of GUIObject
                -- so as to mix with the "Opacity" property that does not exist within GUIItems.
                local propertySetterFuncActualOverride = propertySetterFuncActual
                if altPropertyName == "Color" and itemName ~= "rootItem" then
                    local item = self[itemName]
                    assert(item)
                    if item:isa("GUIItem") then
                        propertySetterFuncActualOverride = GetFakePropertySetter(itemName)
                    end
                end
                
                local result = PerformSetterDuties(self, propertyName, value, propertySetterFuncActualOverride, altPropertyName)
                return result
            end
            
        else
            
            -- Regular setter.
            newSetter = function(self, value)
                local result = PerformSetterDuties(self, propertyName, value, propertySetterFuncActual, altPropertyName)
                return result
            end
            
        end
        
        autoGeneratedSetters[key] = newSetter
        
    end
    
    return autoGeneratedSetters[key]
    
end

-- Returns a function to act as a RawSetter for the given property name.  If a preexisting one
-- cannot be found, a new one is generated.
local autoGeneratedRawSetters = {}
function GUIObject.GetAutoGeneratedRawSetter(propertyName, propertyType, itemName, altPropertyName)
    
    assert(type(propertyType) == "string")
    
    itemName = itemName or "rootItem"
    altPropertyName = altPropertyName or propertyName
    
    if not autoGeneratedRawSetters[propertyName] then
        
        local isFake = GetIsaFakeProperty(altPropertyName)
        local propertySetterFuncActual = isFake and GetFakePropertySetter(itemName) or InstancePropertySetter
        
        if propertyType == "Vector" then
            
            -- Vector-type properties can be set with two or three numbers instead of a Vector type.
            newSetter = function(self, p1, p2, p3)
                local value = ProcessVectorInput(p1, p2, p3)
                local result = PerformSetterDuties(self, propertyName, value, propertySetterFuncActual, altPropertyName, true)
                return result
            end
            
        elseif propertyType == "Color" then
            
            -- Color-type properties can be set with three or four numbers instead of a Color type.
            newSetter = function(self, p1, p2, p3, p4)
                local value = ProcessColorInput(p1, p2, p3, p4)
    
                -- If they are trying to set the "Color" property of a GUIItem, override the setter.
                -- This is a special exception due to how "Color" is used as a property of GUIObject
                -- so as to mix with the "Opacity" property that does not exist within GUIItems.
                local propertySetterFuncActualOverride = propertySetterFuncActual
                if altPropertyName == "Color" and itemName ~= "rootItem" then
                    local item = self[itemName]
                    assert(item)
                    if item:isa("GUIItem") then
                        propertySetterFuncActualOverride = GetFakePropertySetter(itemName)
                    end
                end
                
                local result = PerformSetterDuties(self, propertyName, value, propertySetterFuncActualOverride, altPropertyName, true)
                return result
            end
            
        else
            
            -- Regular setter.
            newSetter = function(self, value)
                local result = PerformSetterDuties(self, propertyName, value, propertySetterFuncActual, altPropertyName, true)
                return result
            end
            
        end
        
        autoGeneratedSetters[propertyName] = newSetter
        
    end
    
    return autoGeneratedRawSetters[propertyName]
    
end

-- Returns a function to act as a Getter for the given property name.  If a preexisting one cannot
-- be found, a new one is generated.
local autoGeneratedGetters = {}
function GUIObject.GetAutoGeneratedGetter(propertyName)
    
    if not autoGeneratedGetters[propertyName] then
    
        local isFake = GetIsaFakeProperty(propertyName)
        local getterActual = isFake and FakePropertyGetter or InstancePropertyGetter
        
        local newGetter = function(self, static)
            local result = PerformGetterDuties(self, propertyName, static, getterActual)
            assert(result ~= nil)
            return result
            
        end
        autoGeneratedGetters[propertyName] = newGetter
        
    end
    
    return autoGeneratedGetters[propertyName]
    
end

-- Declare "Setters" and "Getters" for GUIObject to directly access the values of its root GUIItem.
for fakePropertyName, fakePropertyData in pairs(g_GUIItemFakeProperties) do
    AutomaticallyDefineSetterAndGetter(GUIObject, fakePropertyName, fakePropertyData.type)
end

-- Sets the GUIObject's size to the texture dimensions.  You can optionally provide a (uniform)
-- scale factor.
function GUIObject:SetSizeFromTexture(mult)
    self:SetSize(self:GetTextureWidth() * (mult or 1), self:GetTextureHeight() * (mult or 1))
end

-- Sets the font and scale of this GUIObject based on the font family name, the desired size of the
-- font, and the scaling of its parents.  Local scale is assumed to be 1, 1 when calculating the
-- new scale.  Also takes into account if all characters in the text can be rendered by the font,
-- and if not, uses a fallback font instead.
function GUIObject:SetFont(fontFamilyName, localSize)
    
    -- Parameters can optionally be passed in as a table with fields "family" and "size"
    if type(fontFamilyName) == "table" then
        localSize = fontFamilyName.size
        fontFamilyName = fontFamilyName.family
    end
    
    -- Choose the font that is the best size for how big the text will be on screen -- not
    -- necessarily the same as its local size (eg it could have a tiny local size, but be scaled
    -- way up by parents).
    self:GetRootItem():SetScale(1, 1) -- don't fire on changed events, call through root item.
    local absoluteScale = self:GetAbsoluteScale()
    local absoluteSize = math.min(math.abs(absoluteScale.x) * localSize, math.abs(absoluteScale.y) * localSize)
    local fontFile, fallbackScaling = GetMostSuitableFont(fontFamilyName, self:GetText(), absoluteSize)
    local fontActualSize = GetFontActualSize(fontFile)
    local fontScaleFactor = (localSize / fontActualSize) * fallbackScaling
    self:SetScale(fontScaleFactor.x / absoluteScale.x, fontScaleFactor.y / absoluteScale.y) -- cancel out parent's scale.
    self:SetFontName(fontFile)
    
end

-- Creates a new property for this class.  Properties store state, provide an interface to their
-- values, can be animated, and can automatically provide callbacks for when their value changes.
-- Class properties are automatically created for every instantiation of a class at initialization.
-- This method can only be called before the first instantiation of a class.
function GUIObject.AddClassProperty(cls, propertyName, defaultValue, noCopy)
    
    noCopy = (noCopy == true)
    
    -- Check propertyName and defaultValue.
    ValidatePropertyCreation(propertyName, nil, cls, defaultValue)
    
    -- Ensure this class has not yet been instantiated.  Would cause problems later if a property
    -- is assumed to exist in all instances, but doesn't.
    if classInstantiated[cls] then
        error(string.format("Attempt to add class property to class '%s' which has already been instantiated at least once!", cls.classname), 2)
    end
    
    -- Maintain a list of class properties so we can add them all to each instantiation.
    if not cls._classPropList then
        cls._classPropList = {}
    else
        -- When the "class" function is used in NS2-lua, it creates a full copy of the base class,
        -- so in order to detect a "missing" table, we just check if it's the exact same table as
        -- the base class.
        local baseClass = GetBaseClass(cls)
        
        if baseClass and rawequal(cls._classPropList, baseClass._classPropList) then
            cls._classPropList = Copy(baseClass._classPropList) -- copy from the base class.
        end
    end
    table.insert(cls._classPropList, propertyName)
    
    -- Add property fields to object.
    assert(noCopy ~= nil)
    
    cls[GetClassPropertyNoCopyFieldName(propertyName)] = noCopy
    if noCopy then
        cls[GetClassPropertyFieldName(propertyName)] = defaultValue
    else
        cls[GetClassPropertyFieldName(propertyName)] = Copy(defaultValue)
    end
    
    -- Define setter and getter for this property, if they do not already exist.
    AutomaticallyDefineSetterAndGetter(cls, propertyName, GetTypeName(defaultValue))
    
end

-- Creates a new property for this particular GUIObject.  Properties store state, provide an
-- interface to their values, can be animated, and can automatically provide callbacks for when
-- their value changes.  Instance properties only exist for the GUIObject they are created for --
-- they are not automatically created for other instances of the same class.
-- If a property is going to be used in every single instance of a class, you should create it as a
-- class property instead -- this way the setters and getters are shared, and take up less memory.
function GUIObject:AddInstanceProperty(propertyName, defaultValue, noCopy)
    
    AssertIsNotDestroyed(self)
    
    -- Check propertyName and defaultValue.
    ValidatePropertyCreation(propertyName, self, nil, defaultValue)
     
    -- Add property field to object.
    if noCopy then
        self[GetInstancePropertyFieldName(propertyName)] = defaultValue
    else
        self[GetInstancePropertyFieldName(propertyName)] = Copy(defaultValue)
    end
    
    -- Add property name to a list of instance property names.
    self._instancePropList = self._instancePropList or {}
    table.insert(self._instancePropList, propertyName)
    
    -- Define setter and getter for this property, if they do not already exist.
    AutomaticallyDefineSetterAndGetter(self, propertyName, GetTypeName(defaultValue))
    
end

-- Returns the name of the child item/object that owns the property that is referenced in this object's
-- composite property.
function GUIObject:GetCompositePropertyOwnerName(propertyName)
    
    if not self:GetPropertyExists(propertyName) then
        error(string.format("Property '%s' not found! (Neither real nor composite ref)", propertyName), 2)
    end
    
    if self:GetPropertyExists(propertyName, true) then
        error(string.format("Property '%s' is not a composite ref", propertyName), 2)
    end
    
    local ownerName = self[GetCompositeClassPropertyFieldName(propertyName)]
    assert(ownerName)
    return ownerName
    
end

-- Returns the GUIObject or GUIItem that owns the property that is referenced in this object's
-- composite property.
function GUIObject:GetCompositePropertyOwner(propertyName)
    
    local ownerName = self:GetCompositePropertyOwnerName(propertyName)
    local owner = self[ownerName]
    if owner == nil then
        error(string.format("Unable to trace real property from composite reference.  Child object named '%s' does not exist!", ownerName), 2)
    end
    
    return owner
    
end

-- Returns the owner's name for the referenced property.
function GUIObject:GetCompositePropertyRealName(propertyName)
    
    if not self:GetPropertyExists(propertyName) then
        error(string.format("Property '%s' not found! (Neither real nor composite ref)", propertyName), 2)
    end
    
    if self:GetPropertyExists(propertyName, true) then
        error(string.format("Property '%s' is not a composite ref", propertyName), 2)
    end
    
    local altPropertyName = self[GetCompositeClassPropertyOtherName(propertyName)] or propertyName
    return altPropertyName
    
end

-- Provides direct access to a member object's property via this class.  If propertyName isn't the
-- same in both classes, the member object's propertyName can be specified using
-- optionalOtherPropertyName (otherwise leave nil).
function GUIObject.AddCompositeClassProperty(cls, propertyName, memberObjectName, optionalOtherPropertyName)
    
    ValidatePropertyName(propertyName, 1)
    
    if optionalOtherPropertyName ~= nil then
        ValidatePropertyName(optionalOtherPropertyName)
    end
    
    if type(memberObjectName) ~= "string" then
        error(string.format("Expected the name of a member object, got %s-type instead.", GetTypeName(memberObjectName)), 2)
    end
    
    -- Ensure this class has not yet been instantiated.  Would cause problems later if a property
    -- is assumed to exist in all instances, but doesn't.
    if classInstantiated[cls] then
        error(string.format("Attempt to add class composite property to class '%s' which has already been instantiated at least once!", cls.classname), 2)
    end
    
    -- Maintain a list of composite class property names.
    if not cls._classCompositePropList then
        cls._classCompositePropList = {}
    else
        -- When the "class" function is used in NS2-lua, it creates a full copy of the base class,
        -- so in order to detect a "missing" table, we just check if it's the exact same table as
        -- the base class.
        local baseClass = GetBaseClass(cls)
        
        if baseClass and rawequal(cls._classCompositePropList, baseClass._classCompositePropList) then
            cls._classCompositePropList = Copy(baseClass._classCompositePropList) -- copy from the base class.
        end
    end
    table.insert(cls._classCompositePropList, propertyName)
    
    -- This class can reference another object's property using a different name.
    local thisPropertyName = propertyName
    local memberPropertyName = optionalOtherPropertyName ~= nil and optionalOtherPropertyName or propertyName
    
    -- Make note of what the other object calls the property if it differs.
    cls[GetCompositeClassPropertyFieldName(thisPropertyName)] = memberObjectName
    if memberPropertyName ~= thisPropertyName then
        cls[GetCompositeClassPropertyOtherName(thisPropertyName)] = memberPropertyName
    end
    
    -- Define setter and getter for this property that simply passes the call through to the member
    -- object (if setters and getters aren't manually defined).
    local getterName = GetGetterNameForProperty(thisPropertyName)
    if not cls[getterName] then
        cls[getterName] = function(self, static)
            local memberObject = self[self[GetCompositeClassPropertyFieldName(thisPropertyName)]]
            assert(memberObject ~= nil)
            local memberPropertyName = self[GetCompositeClassPropertyOtherName(thisPropertyName)] or thisPropertyName
            local result
            
            -- Need to omit the "static" parameter for GUIItems, otherwise the engine will complain.
            local getterName = GetGetterNameForProperty(memberPropertyName)
            if memberObject:isa("GUIItem") then
                result = memberObject[getterName](memberObject)
            else
                result = memberObject[getterName](memberObject, static)
            end
            
            assert(result ~= nil)
            return result
        end
    end
    
    local setterName = GetSetterNameForProperty(thisPropertyName)
    if not cls[setterName] then
        cls[setterName] = function(self, p1, p2, p3, p4)
            local memberObjectName = self[GetCompositeClassPropertyFieldName(thisPropertyName)]
            local memberObject = self[memberObjectName]
            assert(memberObject ~= nil)
            local memberPropertyName = self[GetCompositeClassPropertyOtherName(thisPropertyName)] or thisPropertyName
            
            -- memberObject can be either a GUIObject or a GUIItem.
            if memberObject:isa("GUIObject") then
                
                -- If it is a GUIObject, all we have to do is forward the call to the object.
                local result = memberObject[GetSetterNameForProperty(memberPropertyName)](memberObject, p1, p2, p3, p4)
                return result
                
                -- We do not need to fire any On_____Changed events from this.  They will be
                -- automatically forwarded from the property's actual location.
                
            else
                
                -- If it is a GUIItem, we need to make sure we're dispatching the correct events and such.
                local propertyType = g_GUIItemPropertyTypes[memberPropertyName]
                assert(propertyType)
                local setter = GUIObject.GetAutoGeneratedSetter(thisPropertyName, propertyType, memberObjectName, memberPropertyName)
                local result = setter(self, p1, p2, p3, p4)
                return result
                
            end
        end
    end
    
    local rawSetterName = GetRawSetterNameForProperty(thisPropertyName)
    if not cls[rawSetterName] then
        cls[rawSetterName] = function(self, p1, p2, p3, p4)
            local memberObjectName = self[GetCompositeClassPropertyFieldName(thisPropertyName)]
            local memberObject = self[memberObjectName]
            assert(memberObject ~= nil)
            local memberPropertyName = self[GetCompositeClassPropertyOtherName(thisPropertyName)] or thisPropertyName
            
            -- memberObject can be either a GUIObject or a GUIItem.
            if memberObject:isa("GUIObject") then
                
                -- If it is a GUIObject, all we have to do is forward the call to the object.
                local result = memberObject[GetSetterNameForProperty(memberPropertyName)](memberObject, p1, p2, p3, p4)
                return result
                
                -- We do not need to fire any On_____Changed events from this.  They will be
                -- automatically forwarded from the property's actual location.
            
            else
                
                -- If it is a GUIItem, we need to make sure we're dispatching the correct events and such.
                local propertyType = g_GUIItemPropertyTypes[memberPropertyName]
                assert(propertyType)
                local rawSetter = GUIObject.GetAutoGeneratedRawSetter(thisPropertyName, propertyType, memberObjectName, memberPropertyName)
                local result = rawSetter(self, p1, p2, p3, p4)
                return result
            
            end
        end
    end
    
end

-- Returns true if a property with the given name exists for this object (including GUIItem
-- properties).
function GUIObject:GetPropertyExists(propertyName, prohibitCompositeRefs, errorDepth)
    errorDepth = (errorDepth or 1) + 1

    local result
    if type(self) == "table" then -- class is asking
        result = GetPropertyExistsForClass(self, propertyName, prohibitCompositeRefs, errorDepth)
    else
        result = GetPropertyExistsForGUIObject(self, propertyName, prohibitCompositeRefs, errorDepth)
    end

    return result
    
end

-- Returns the value of the given property belonging to this object.
function GUIObject:Get(propertyName, static)
    AssertIsaGUIObject(self)
    AssertIsNotDestroyed(self)
    local result = self[GetGetterNameForProperty(propertyName)](self, static)
    return result
end

-- Sets the value of the given property belonging to this object.  Will also set the value of the
-- root GUIItem's properties (eg "Position").
function GUIObject:Set(propertyName, p1, p2, p3, p4)
    AssertIsaGUIObject(self)
    AssertIsNotDestroyed(self)
    local result = self[GetSetterNameForProperty(propertyName)](self, p1, p2, p3, p4)
    return result
end

-- Sets the value of the given property belonging to this object, but without doing anything else
-- (eg no adjustments, no animation considerations, no "On_____Changed" events).
function GUIObject:RawSet(propertyName, p1, p2, p3, p4)
    AssertIsaGUIObject(self)
    AssertIsNotDestroyed(self)
    local result = self[GetRawSetterNameForProperty(propertyName)](self, p1, p2, p3, p4)
    return result
end

-- Returns the type of the value of the property with the given name.
function GUIObject:GetPropertyType(propertyName)
    AssertIsaGUIObject(self)
    AssertIsNotDestroyed(self)
    local result = GetTypeName(self:Get(propertyName))
    return result
end

-- See GUIAnimationManager for details.
function GUIObject:AnimateProperty(propertyName, value, animationParams, optionalName)
    AssertIsaGUIObject(self)
    AssertIsNotDestroyed(self)
    GetGUIAnimationManager():AnimateObjectProperty(self, propertyName, value, animationParams, optionalName)
end

-- Clears the animations for a given property name for this object.  If optionalAnimationName
-- is provided, only animations with this name will be cleared.
function GUIObject:ClearPropertyAnimations(propertyName, optionalAnimationName)
    AssertIsaGUIObject(self)
    GetGUIAnimationManager():ClearAnimationsForProperty(self, propertyName, optionalAnimationName)
end

function GUIObject:GetIsAnimationPlaying(propertyName, animationName)
    return (GetGUIAnimationManager():GetPropertyHasAnimation(self, propertyName, animationName))
end

-- Optimization: GUIObject is the base class, so we only need to check if className is "GUIObject".
function GUIObject:isa(className)
    return className == "GUIObject"
end

function GUIObject:__tostring()
    local result
    if type(self) == "table" then -- class calling its own __tostring method
        result = string.format("class %s", self.classname)
    else -- userdata calling it's __tostring metamethod.
        result = string.format("%s { name = %s }", self.classname, self.name)
    end
    return result
end

-- Define "Color" and "Opacity" properties.  We need to do a bit of tinkering here because in the
-- engine, GUIItems don't have a separate "Opacity" property, so we need to combine them and set the
-- GUIItem's color whenever one or the other changes.
GUIObject:AddClassProperty("Color", Color(0, 0, 0, 0))
GUIObject:AddClassProperty("Opacity", 1)
do
    local colorSetterName = GetSetterNameForProperty("Color")
    local opacitySetterName = GetSetterNameForProperty("Opacity")
    local colorFieldName = GetInstancePropertyFieldName("Color")
    local opacityFieldName = GetInstancePropertyFieldName("Opacity")
    local sharedItemColorSetterFunc = function(self)
        local opacity = self:GetOpacity()
        local color = self:GetColor()
        local result = color * Color(1, 1, 1, opacity)
        self.rootItem:SetColor(result)
    end
    local colorSetterFuncActual = function(self, propertyName, value)
        self[colorFieldName] = Copy(value)
        sharedItemColorSetterFunc(self)
    end
    local opacitySetterFuncActual = function(self, propertyName, value)
        self[opacityFieldName] = value
        sharedItemColorSetterFunc(self)
    end
    local colorSetter = function(self, p1, p2, p3, p4)
        local value = ProcessColorInput(p1, p2, p3, p4)
        local result = PerformSetterDuties(self, "Color", value, colorSetterFuncActual)
        return result
    end
    local opacitySetter = function(self, value)
        local result = PerformSetterDuties(self, "Opacity", value, opacitySetterFuncActual)
        return result
    end
    GUIObject[colorSetterName] = colorSetter
    GUIObject[opacitySetterName] = opacitySetter
end

-- Convenience.  Calls SetPosition() on this object, but with the y component set to GetPosition().y.
function GUIObject:SetX(xOrVec)
    
    RequireType({"number", "Vector"}, xOrVec, "xOrVec")
    
    local xActual
    if type(xOrVec) == "number" then
        xActual = xOrVec
    else
        xActual = xOrVec.x
    end
    
    return (self:SetPosition(xActual, self:GetPosition().y))
    
end

-- Convenience.  Calls SetPosition() on this object, but with the x component set to GetPosition().x.
function GUIObject:SetY(yOrVec)
    
    RequireType({"number", "Vector"}, yOrVec, "yOrVec")
    
    local yActual
    if type(yOrVec) == "number" then
        yActual = yOrVec
    else
        yActual = yOrVec.y
    end
    
    return (self:SetPosition(self:GetPosition().x, yActual))
    
end

-- Convenience.  Calls SetSize() on this object, but with the height value set to GetSize().y.
function GUIObject:SetWidth(widthOrVector)
    
    RequireType({"number", "Vector"}, widthOrVector, "widthOrVector")
    
    local widthActual
    if type(widthOrVector) == "number" then
        widthActual = widthOrVector
    else
        widthActual = widthOrVector.x
    end
    
    return (self:SetSize(widthActual, self:GetSize().y))
    
end

-- Convenience.  Calls SetSize() on this object, but with the width value set to GetSize().x.
function GUIObject:SetHeight(heightOrVector)
    
    RequireType({"number", "Vector"}, heightOrVector, "heightOrVector")
    
    local heightActual
    if type(heightOrVector) == "number" then
        heightActual = heightOrVector
    else
        heightActual = heightOrVector.y
    end
    
    return (self:SetSize(self:GetSize().x, heightActual))
    
end

function GUIObject:GetTextureSize()
    return (self:GetRootItem():GetTextureSize())
end


