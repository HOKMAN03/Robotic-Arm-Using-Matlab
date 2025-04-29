classdef Encoder_arduino < realtime.internal.SourceSampleTime ...
        & coder.ExternalDependency ...
        & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon 
    %
    % Read the position of two quadrature encoders.
    %
     
    %#codegen
    %#ok<*EMCA>
    
    properties (Nontunable)
        Encoder1 = 0
        PinA1 = 2
        PinB1 = 3
        
        Encoder2 = 1
        PinA2 = 21
        PinB2 = 20
    end
    
    properties (Constant, Hidden)
        AvailablePin = 0:53;
        MaxNumEncoder = 3;
    end
    
    methods
        % Constructor
        function obj = DualEncoder_arduino(varargin)
            coder.allowpcode('plain');
            % Support name-value pair arguments when constructing the object.
            setProperties(obj, nargin, varargin{:});
        end
        
        function set.PinA1(obj, value)
            coder.extrinsic('sprintf');
            validateattributes(value, {'numeric'}, {'real', 'nonnegative', 'integer', 'scalar'}, '', 'PinA1');
            assert(any(value == obj.AvailablePin), 'Invalid value for Pin. Pin must be one of the following: %s', sprintf('%d ', obj.AvailablePin));
            obj.PinA1 = value;
        end
        
        function set.PinB1(obj, value)
            coder.extrinsic('sprintf');
            validateattributes(value, {'numeric'}, {'real', 'nonnegative', 'integer', 'scalar'}, '', 'PinB1');
            assert(any(value == obj.AvailablePin), 'Invalid value for Pin. Pin must be one of the following: %s', sprintf('%d ', obj.AvailablePin));
            obj.PinB1 = value;
        end
        
        function set.PinA2(obj, value)
            coder.extrinsic('sprintf');
            validateattributes(value, {'numeric'}, {'real', 'nonnegative', 'integer', 'scalar'}, '', 'PinA2');
            assert(any(value == obj.AvailablePin), 'Invalid value for Pin. Pin must be one of the following: %s', sprintf('%d ', obj.AvailablePin));
            obj.PinA2 = value;
        end
        
        function set.PinB2(obj, value)
            coder.extrinsic('sprintf');
            validateattributes(value, {'numeric'}, {'real', 'nonnegative', 'integer', 'scalar'}, '', 'PinB2');
            assert(any(value == obj.AvailablePin), 'Invalid value for Pin. Pin must be one of the following: %s', sprintf('%d ', obj.AvailablePin));
            obj.PinB2 = value;
        end
        
        function set.Encoder1(obj, value)
            validateattributes(value, {'numeric'}, {'real', 'nonnegative', 'integer', 'scalar', '>=', 0, '<=', obj.MaxNumEncoder}, '', 'Encoder1');
            obj.Encoder1 = value;
        end
        
        function set.Encoder2(obj, value)
            validateattributes(value, {'numeric'}, {'real', 'nonnegative', 'integer', 'scalar', '>=', 0, '<=', obj.MaxNumEncoder}, '', 'Encoder2');
            obj.Encoder2 = value;
        end
    end
    
    methods (Access = protected)
        function setupImpl(obj)
            if coder.target('Rtw')
                % Call initialization for both encoders
                coder.cinclude('encoder_arduino.h');
                coder.ceval('enc_init', obj.Encoder1, obj.PinA1, obj.PinB1);
                coder.ceval('enc_init', obj.Encoder2, obj.PinA2, obj.PinB2);
            end
        end

        function varargout = isOutputComplexImpl(~)
    varargout{1} = false; % Output 1 is real
    varargout{2} = false; % Output 2 is real
end

        
        function [y1, y2] = stepImpl(obj)
            y1 = int32(0);
            y2 = int32(0);
            if coder.target('Rtw')
                % Read encoder outputs
                y1 = coder.ceval('enc_output', obj.Encoder1);
                y2 = coder.ceval('enc_output', obj.Encoder2);
            end
        end
        
        function releaseImpl(obj) %#ok<MANU>
        end
    end
    
    methods (Access = protected)
        function num = getNumInputsImpl(~)
            num = 0;
        end
        
        function num = getNumOutputsImpl(~)
            num = 2;
        end
        
        function flag = isOutputSizeLockedImpl(~, ~)
            flag = true;
        end
        
        function varargout = isOutputFixedSizeImpl(~, ~)
            varargout{1} = true;
            varargout{2} = true;
        end
        
        function flag = isOutputComplexityLockedImpl(~, ~)
            flag = true;
        end
        
        function varargout = getOutputSizeImpl(~)
            varargout{1} = [1, 1];
            varargout{2} = [1, 1];
        end
        
        function varargout = getOutputDataTypeImpl(~)
            varargout{1} = 'int32';
            varargout{2} = 'int32';
        end
        
        function icon = getIconImpl(~)
            icon = 'Dual Encoder';
        end
    end
    
    methods (Static, Access = protected)
        function simMode = getSimulateUsingImpl(~)
            simMode = 'Interpreted execution';
        end
        
        function isVisible = showSimulateUsingImpl
            isVisible = false;
        end
    end
    
    methods (Static)
        function name = getDescriptiveName()
            name = 'Dual Encoder';
        end
        
        function b = isSupportedContext(context)
            b = context.isCodeGenTarget('rtw');
        end
        
        function updateBuildInfo(buildInfo, context)
            if context.isCodeGenTarget('rtw')
                rootDir = fullfile(fileparts(mfilename('fullpath')), '..', 'src');
                buildInfo.addIncludePaths(rootDir);
                buildInfo.addIncludeFiles('encoder_arduino.h');
                buildInfo.addSourceFiles('encoder_arduino.cpp', rootDir);
            end
        end
    end
end
